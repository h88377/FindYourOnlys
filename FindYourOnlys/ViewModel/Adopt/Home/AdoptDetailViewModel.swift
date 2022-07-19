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
    
    let favoritePets = Box([Pet]())
    
    var error: Box<Error?> = Box(nil)
    
    var pet: Box<Pet>
    
    init(pet: Box<Pet>) {
        
        self.pet = pet
    }
    
    var isFavorite = false
    
    private var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    private var favoriteLSPets = [LSPet]()
    
    var favoriteChangedHandler: ((Bool) -> Void)?
    
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
        
        favoritePets.bind { pets in
            
            self.isFavorite = pets.contains { $0.id == self.pet.value.id }
            
            self.favoriteChangedHandler?(self.isFavorite)
        }
    }
    
    private func fetchFavoritePetFromFB() {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                let favoritePets = pets.filter { $0.userID == currentUser.id }
                
                self.favoritePets.value = favoritePets
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func fetchLSFavoritePet() {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let pets = StorageManager.shared.convertLsPetsToPets(from: lsPets)
                
                self.favoritePets.value = pets
                
                self.favoriteLSPets = lsPets
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func addFavoritePetInCloud() {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.saveFavoritePet(
            currentUser.id,
            with: pet.value
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.error.value = error
            }
        }
    }
    
    private func addFavoritePetInLS() {
        
        StorageManager.shared.savePetInFavorite(with: pet.value) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.error.value = error
            }
        }
    }
    
    private func removeLSFavorite() {
        
        let removeId = pet.value.id
        
        for favoriteLSPet in favoriteLSPets where favoriteLSPet.id == removeId {
            
            StorageManager.shared.removePetfromFavorite(lsPet: favoriteLSPet) { [weak self] result in
                
                guard let self = self else { return }
                
                if case .failure(let error) = result {
                    
                    self.error.value = error
                }
            }
        }
    }
    
    private func removeCloudFavorite() {
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: pet.value) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .failure(let error) = result {
                
                self.error.value = error
            }
        }
    }
}
