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
    
//    var isFavoritePetViewModel: Box<ResultViewModel?> = Box(nil)
    
    var selectedPetIsFavorite: Box<Bool?> = Box(nil)

    var filterConditionViewModel = Box(
        AdoptFilterCondition(
        city: "",
        petKind: "",
        sex: "",
        color: ""
        )
    )
    
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
    
    private var favoritePetsFromLS = [LSPet]()
    
    // MARK: - Methods
    
    func fetchPet() {
        
        PetProvider.shared.fetchPet(
            with: filterConditionViewModel.value, paging: currentPage + 1
        ) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                if pets.count > 0 {
                    
                    self?.appendPets(pets)
                    
                    self?.stopIndicatorHandler?()
                    
                    self?.stopLoadingHandler?()
                    
                    self?.currentPage += 1
                    
                } else {
                    
                    self?.noMorePetHandler?()
                    
                    self?.stopIndicatorHandler?()
                    
                    self?.stopLoadingHandler?()
                    
                    return
                }
                  
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopIndicatorHandler?()
                
                self?.stopLoadingHandler?()
            }
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
                
                self.stopIndicatorHandler?()
                
                self.stopLoadingHandler?()
                
                self.currentPage += 1
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopIndicatorHandler?()
                
                self.stopLoadingHandler?()
            }
        }
    }
    
    func resetFilterCondition() {
        
        filterConditionViewModel.value = AdoptFilterCondition(
            city: "",
            petKind: "",
            sex: "",
            color: ""
            )
        
        currentPage = 0
    }
    
    func fetchFavoritePet(at index: Int) {
        
        let petViewModel = petViewModels.value[index]
        
        if didSignIn {
            
            fetchFavoritePetFromFB(with: petViewModel)
            
        } else {
            
            fetchFavoritePetFromLS(with: petViewModel)
        }
    }
    
    func toggleFavoritePet() {
        
        if
            let selectedPetIsFavorite = selectedPetIsFavorite.value {
            
            if selectedPetIsFavorite {
                
                removeFavoritePet()
                
            } else {
                
                addPetInFavorite()
            }
        }
    }
    
    private func fetchFavoritePetFromFB(with petViewModel: PetViewModel) {
        
        FavoritePetFirebaseManager.shared.fetchFavoritePet(pet: petViewModel.pet) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
//                self.isFavoritePetViewModel.value = ResultViewModel(model: pets.count != 0)
                
                self.selectedPetIsFavorite.value = pets.count != 0
                
                self.selectedPetViewModel.value = petViewModel
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func fetchFavoritePetFromLS(with petViewModel: PetViewModel) {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let isFavorite = lsPets.map { $0.id }.contains(Int64(petViewModel.pet.id))
                
//                self.isFavoritePetViewModel.value = ResultViewModel(model: isFavorite)
                
                self.selectedPetIsFavorite.value = isFavorite
                
                self.selectedPetViewModel.value = petViewModel
                
                self.favoritePetsFromLS = lsPets
                
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
            
            addFavoritePetInFB(currentUser: currentUser, with: selectedViewModel)
            
        } else {
            
            addFavoritePetInLS(with: selectedViewModel)
        }
    }
    
    private func addFavoritePetInFB(currentUser: User, with viewModel: PetViewModel) {
        
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
            
            removeFavoriteFromFB(currentUser: currentUser, with: selectedViewModel)
            
        } else {
            
            removeFavoriteFromLS(with: selectedViewModel)
        }
    }
    
    private func removeFavoriteFromFB(currentUser: User, with viewModel: PetViewModel) {
        
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

    private func removeFavoriteFromLS(with viewModel: PetViewModel) {
        
        let removeId = viewModel.pet.id
        
        for favoritePetFromLS in favoritePetsFromLS where favoritePetFromLS.id == removeId {
            
            StorageManager.shared.removePetfromFavorite(lsPet: favoritePetFromLS) { [weak self] result in
                
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
