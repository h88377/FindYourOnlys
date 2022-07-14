//
//  AdoptFavoriteViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation

class AdoptFavoriteViewModel {
    
    // MARK: - Properties
    let favoritePetViewModels = Box([PetViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    private var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    // MARK: - Methods
    func fetchFavoritePets() {
        
        if didSignIn {
            
            fetchCloudFavoritePets()
            
        } else {
            
            fetchLSFavoritePets()
        }
    }
    
    private func fetchCloudFavoritePets() {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                var favoritePets: [Pet] = []
                
                for pet in pets where pet.userID == currentUser.id {
                    
                    favoritePets.append(pet)
                }
                
                self.favoritePetViewModels.value = favoritePets.map { PetViewModel(model: $0) }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func fetchLSFavoritePets() {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let pets = StorageManager.shared.convertLsPetsToPets(from: lsPets)
                
                self.favoritePetViewModels.value = pets.map { PetViewModel(model: $0) }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
