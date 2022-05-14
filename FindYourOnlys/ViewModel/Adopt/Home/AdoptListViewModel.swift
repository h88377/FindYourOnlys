//
//  AdoptListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

class AdoptListViewModel {
    
    let petViewModels = Box([PetViewModel]())
    
    var isFavoritePetViewModel: Box<ResultViewModel?> = Box(nil)
    
    var selectedPetViewModel: Box<PetViewModel?> = Box(nil)
    
    var filterConditionViewModel = Box(
        AdoptFilterCondition(
        city: "",
        petKind: "",
        sex: "",
        color: ""
        )
    )
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var currentPage = 0
    
    var stopIndicatorHandler: (() -> Void)?
    
    var startIndicatorHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var resetPetHandler: (() -> Void)?
    
    var noMorePetHandler: (() -> Void)?
    
    func fetchFavoritePet(at index: Int) {
        
        let petViewModel = petViewModels.value[index]
        
        FavoritePetFirebaseManager.shared.fetchFavoritePet(pet: petViewModel.pet) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                self.isFavoritePetViewModel.value = ResultViewModel(model: pets.count != 0)
                
                self.selectedPetViewModel.value = petViewModel
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func addToFavoriteInFB() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser,
            let viewModel = selectedPetViewModel.value
                
        else { return }
        
        FavoritePetFirebaseManager.shared.saveFavoritePet(currentUser.id, with: viewModel) { [weak self] result in
            
            switch result {
                
            case .success(let success):
                
                self?.selectedPetViewModel.value = nil
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func removeFavoriteFromFB() {
        
        guard
            let viewModel = selectedPetViewModel.value,
            let currentUser = UserFirebaseManager.shared.currentUser
        
        else { return }
        
        viewModel.pet.userID = currentUser.id
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: viewModel) { [weak self] result in
            
            switch result {
                
            case .success(let success):
                
                print(success)
                
                self?.selectedPetViewModel.value = nil
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func fetchPet() {
        
        // Need to change header loader
//        startIndicatorHandler?()
        
        PetProvider.shared.fetchPet(with: filterConditionViewModel.value, paging: currentPage + 1) { [weak self] result in
            
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
        
        // Need to change header loader
//        startIndicatorHandler?()
        startLoadingHandler?()
        
        resetPetHandler?()
        
        PetProvider.shared.fetchPet(with: filterConditionViewModel.value, paging: currentPage + 1) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.setPets(pets)
                
                self?.stopIndicatorHandler?()
                
                self?.stopLoadingHandler?()
                
                self?.currentPage += 1
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopIndicatorHandler?()
                
                self?.stopLoadingHandler?()
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
    
    private func convertPetsToViewModels(from pets: [Pet]) -> [PetViewModel] {
        
        var viewModels = [PetViewModel]()
        
        for pet in pets {
            
            let viewModel = PetViewModel(model: pet)
            
            viewModels.append(viewModel)
        }
        return viewModels
    }
    
    private func setPets(_ pets: [Pet]) {
        
        petViewModels.value = convertPetsToViewModels(from: pets)
    }
    
    private func appendPets(_ pets: [Pet]) {
        
        let appendedPetViewModels = convertPetsToViewModels(from: pets)
        
        petViewModels.value += appendedPetViewModels
    }
}
