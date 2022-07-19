//
//  AdoptListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

class AdoptListViewModel {
    
    // MARK: - Properties
    let pets = Box([Pet]())

    var filteredCondition = Box(AdoptFilterCondition())
    
    var error: Box<Error?> = Box(nil)
    
    var stopIndicatorHandler: (() -> Void)?
    
    var startIndicatorHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var resetPetHandler: (() -> Void)?
    
    var noMorePetHandler: (() -> Void)?
    
    var addToFavoriteHandler: (() -> Void)?
    
    var longPressedHandler: ((Bool) -> Void)?

    private var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    private var currentPage = 0
    
    private var selectedPet: Box<Pet?> = Box(nil)
    
    private var lsFavoritePets = [LSPet]()
    
    private var selectedPetIsFavorite = false
    
    // MARK: - Methods
    
    func fetchPet() {
        
        PetProvider.shared.fetchPet(
            with: filteredCondition.value,
            paging: currentPage + 1
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                if pets.count > 0 {
                    
                    self.pets.value += pets
                    
                    self.currentPage += 1
                    
                } else {
                    
                    self.noMorePetHandler?()
                }
                  
            case .failure(let error):
                
                self.error.value = error
            }
            
            self.stopIndicatorHandler?()
            
            self.stopLoadingHandler?()
        }
    }
    
    func resetFetchPet() {
        
        startLoadingHandler?()
        
        resetPetHandler?()
        
        PetProvider.shared.fetchPet(
            with: filteredCondition.value,
            paging: currentPage + 1
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                self.pets.value = pets
                
                self.currentPage += 1
                
            case .failure(let error):
                
                self.error.value = error
            }
            
            self.stopIndicatorHandler?()
            
            self.stopLoadingHandler?()
        }
    }
    
    func resetFilterCondition() {
        
        filteredCondition.value = AdoptFilterCondition()
        
        currentPage = 0
    }
    
    func fetchFavoritePet(at index: Int) {
        
        let pet = pets.value[index]
        
        if didSignIn {
            
            fetchCloudFavoritePet(with: pet) // cloud
            
        } else {
            
            fetchLSFavoritePet(with: pet)
        }
    }
    
    func toggleFavoritePet() {
        
        if selectedPetIsFavorite {
            
            removeFavoritePet()
            
        } else {
            
            addPetInFavorite()
        }
    }
    
    private func fetchCloudFavoritePet(with pet: Pet) {
        
        FavoritePetFirebaseManager.shared.fetchFavoritePet(pet: pet) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                let isFavorite = pets.count != 0

                self.selectedPetIsFavorite = isFavorite
                
                self.longPressedHandler?(isFavorite)
                
                self.selectedPet.value = pet
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func fetchLSFavoritePet(with pet: Pet) {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let isFavorite = lsPets.map { Int($0.id) }.contains(pet.id)
                
                self.selectedPetIsFavorite = isFavorite
                
                self.longPressedHandler?(isFavorite)
                
                self.selectedPet.value = pet
                
                self.lsFavoritePets = lsPets
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func addPetInFavorite() {
        
        guard let selectedPet = selectedPet.value else { return }
        
        if didSignIn {
            
            guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            addFavoritePetInCloud(currentUser: currentUser, with: selectedPet)
            
        } else {
            
            addFavoritePetInLS(with: selectedPet)
        }
    }
    
    private func addFavoritePetInCloud(currentUser: User, with pet: Pet) {
        
        FavoritePetFirebaseManager.shared.saveFavoritePet(
            currentUser.id,
            with: pet
        ) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success:
                
                self.selectedPet.value = nil
                
                self.addToFavoriteHandler?()
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func addFavoritePetInLS(with pet: Pet) {
        
        StorageManager.shared.savePetInFavorite(with: pet) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success:
                
                self.addToFavoriteHandler?()
                
                self.selectedPet.value = nil
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func removeFavoritePet() {
        
        guard var selectedPet = selectedPet.value else { return }
        
        if didSignIn {
            
            guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
            
            removeCloudFavorite(currentUser: currentUser, with: &selectedPet)
            
        } else {
            
            removeLSFavorite(with: selectedPet)
        }
    }
    
    private func removeCloudFavorite(currentUser: User, with pet: inout Pet) {
        
        pet.userID = currentUser.id
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: pet) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success:
                
                self.selectedPet.value = nil
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }

    private func removeLSFavorite(with pet: Pet) {
        
        let removeId = pet.id
        
        for lsFavoritePet in lsFavoritePets where lsFavoritePet.id == removeId {
            
            StorageManager.shared.removePetfromFavorite(lsPet: lsFavoritePet) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                    
                case .success:
                    
                    self.selectedPet.value = nil
                    
                case .failure(let error):
                    
                    self.error.value = error
                }
            }
        }
    }
}
