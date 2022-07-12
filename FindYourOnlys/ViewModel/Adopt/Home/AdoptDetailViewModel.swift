//
//  AdoptDetailViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation

class AdoptDetailViewModel {
    
    // MARK: - Properties
    
    let adoptDetailContentCategory = AdoptDetailContentCategory.allCases
    
    let favoritePetViewModels = Box([PetViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var petViewModel: Box<PetViewModel>
    
    init(petViewModel: Box<PetViewModel>) {
        
        self.petViewModel = petViewModel
    }
    
    var favoriteChangedHandler: ((Bool) -> Void)?
    
    var isFavorite = false
    
    private var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    private var favoriteLSPets = [LSPet]()
    
    // MARK: - Methods
    
    func fetchFavoritePet() {
        
        if didSignIn {
            
            fetchFavoritePetFromFB()
            
        } else {
            
            fetchLSFavoritePet()
        }
    }
    
    func addPetInFavorite() {
        
        if didSignIn {
            
            addFavoritePetInCloud()
            
        } else {
            
            addFavoritePetInLS()
        }
    }
    
    func removeFavoritePet() {
        
        if didSignIn {
            
            removeCloudFavorite()
            
        } else {
            
            removeLSFavorite()
        }
    }
    
    func toggleFavorite() {
        
        self.isFavorite = !isFavorite
        
        if isFavorite {
            
            addPetInFavorite()
            
        } else {
            
            removeFavoritePet()
        }
    }
    
    func setupFavoriteBinding() {
        
        favoritePetViewModels.bind { petViewModels in
            
            self.isFavorite = petViewModels.contains { $0.pet.id == self.petViewModel.value.pet.id }
            
            self.favoriteChangedHandler?(self.isFavorite)
        }
    }
    
    private func fetchFavoritePetFromFB() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                let favoritePets = pets.filter { $0.userID == currentUser.id }
                
                self.favoritePetViewModels.value = favoritePets.map { PetViewModel(model: $0) }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func fetchLSFavoritePet() {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let pets = StorageManager.shared.convertLsPetsToPets(from: lsPets)
                
                self.favoritePetViewModels.value = pets.map { PetViewModel(model: $0) }
                
                self.favoriteLSPets = lsPets
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func addFavoritePetInCloud() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.saveFavoritePet(
            currentUser.id, with: petViewModel.value
        ) { [weak self] result in
            
            if case .failure(let error) = result {
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func addFavoritePetInLS() {
        
        StorageManager.shared.savePetInFavorite(with: petViewModel.value) { [weak self] result in
            
            if case .failure(let error) = result {
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func removeLSFavorite() {
        
        let removeId = petViewModel.value.pet.id
        
        for favoriteLSPet in favoriteLSPets where favoriteLSPet.id == removeId {
            
            StorageManager.shared.removePetfromFavorite(lsPet: favoriteLSPet) { [weak self] result in
                
                if case .failure(let error) = result {
                    
                    self?.errorViewModel.value = ErrorViewModel(model: error)
                }
            }
        }
    }
    
    private func removeCloudFavorite() {
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: petViewModel.value) { [weak self] result in
            
            if case .failure(let error) = result {
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
