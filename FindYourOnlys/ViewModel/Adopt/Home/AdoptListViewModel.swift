//
//  AdoptListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

class AdoptListViewModel {
    
    // MARK: - Properties
    let petViewModels = Box([PetViewModel]())
    
    var isSelectedPetFavorite: Box<Bool> = Box(false)

    var filterConditionViewModel = Box(AdoptFilterCondition())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var stopIndicatorHandler: (() -> Void)?
    
    var startIndicatorHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var resetPetHandler: (() -> Void)?
    
    var noMorePetHandler: (() -> Void)?
    
    var addToFavoriteHandler: (() -> Void)?

    private var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    private var currentPage = 0
    
    private var selectedPetViewModel: Box<PetViewModel?> = Box(nil)
    
    private var lsFavoritePets = [LSPet]()
    
    // MARK: - Methods
    
    func fetchPet() {
        
        PetProvider.shared.fetchPet(
            with: filterConditionViewModel.value, paging: currentPage + 1
        ) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                if pets.count > 0 {
                    
                    self?.appendPets(pets)
                    
                    self?.currentPage += 1
                    
                } else {
                    
                    self?.noMorePetHandler?()
                }
                  
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
            
            self?.stopIndicatorHandler?()
            
            self?.stopLoadingHandler?()
        }
    }
    
    func resetFetchPet() {
        
        startLoadingHandler?()
        
        resetPetHandler?()
        
        PetProvider.shared.fetchPet(
            with: filterConditionViewModel.value, paging: currentPage + 1
        ) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                PetProvider.shared.setPets(petViewModels: self.petViewModels, with: pets)
                
                self.currentPage += 1
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
            
            self.stopIndicatorHandler?()
            
            self.stopLoadingHandler?()
        }
    }
    
    func resetFilterCondition() {
        
        filterConditionViewModel.value = AdoptFilterCondition()
        
        currentPage = 0
    }
    
    func fetchFavoritePet(at index: Int) {
        
        let petViewModel = petViewModels.value[index]
        
        if didSignIn {
            
            fetchCloudFavoritePet(with: petViewModel) // cloud
            
        } else {
            
            fetchLSFavoritePet(with: petViewModel)
        }
    }
    
    func toggleFavoritePet() {
            
        if isSelectedPetFavorite.value {
            
            removeFavoritePet()
            
        } else {
            
            addPetInFavorite()
        }
    }
    
    private func fetchCloudFavoritePet(with petViewModel: PetViewModel) {
        
        FavoritePetFirebaseManager.shared.fetchFavoritePet(pet: petViewModel.pet) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                self.isSelectedPetFavorite.value = pets.count != 0
                
                self.selectedPetViewModel.value = petViewModel
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func fetchLSFavoritePet(with petViewModel: PetViewModel) {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let isFavorite = lsPets.map { Int($0.id) }.contains(petViewModel.pet.id)
                
                self.isSelectedPetFavorite.value = isFavorite
                
                self.selectedPetViewModel.value = petViewModel
                
                self.lsFavoritePets = lsPets
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func addPetInFavorite() {
        
        guard
            let selectedViewModel = selectedPetViewModel.value
                
        else { return }
        
        if didSignIn {
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser
                    
            else { return }
            
            addFavoritePetInCloud(currentUser: currentUser, with: selectedViewModel)
            
        } else {
            
            addFavoritePetInLS(with: selectedViewModel)
        }
    }
    
    private func addFavoritePetInCloud(currentUser: User, with viewModel: PetViewModel) {
        
        FavoritePetFirebaseManager.shared.saveFavoritePet(currentUser.id, with: viewModel) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.selectedPetViewModel.value = nil
                
                self?.addToFavoriteHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func addFavoritePetInLS(with viewModel: PetViewModel) {
        
        StorageManager.shared.savePetInFavorite(with: viewModel) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.addToFavoriteHandler?()
                
                self?.selectedPetViewModel.value = nil
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func removeFavoritePet() {
        
        guard
            let selectedViewModel = selectedPetViewModel.value
                
        else { return }
        
        if didSignIn {
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser
                    
            else { return }
            
            removeCloudFavorite(currentUser: currentUser, with: selectedViewModel)
            
        } else {
            
            removeLSFavorite(with: selectedViewModel)
        }
    }
    
    private func removeCloudFavorite(currentUser: User, with viewModel: PetViewModel) {
        
        viewModel.pet.userID = currentUser.id
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: viewModel) { [weak self] result in
            
            switch result {
                
            case .success:
                
                self?.selectedPetViewModel.value = nil
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }

    private func removeLSFavorite(with viewModel: PetViewModel) {
        
        let removeId = viewModel.pet.id
        
        for lsFavoritePet in lsFavoritePets where lsFavoritePet.id == removeId {
            
            StorageManager.shared.removePetfromFavorite(lsPet: lsFavoritePet) { [weak self] result in
                
                switch result {
                    
                case .success:
                    
                    self?.selectedPetViewModel.value = nil
                    
                case .failure(let error):
                    
                    self?.errorViewModel.value = ErrorViewModel(model: error)
                }
            }
        }
    }
    
    // Convert
    private func appendPets(_ pets: [Pet]) {
        
        let appendedPetViewModels = PetProvider.shared.convertPetsToViewModels(from: pets)
        
        petViewModels.value += appendedPetViewModels
    }
}
