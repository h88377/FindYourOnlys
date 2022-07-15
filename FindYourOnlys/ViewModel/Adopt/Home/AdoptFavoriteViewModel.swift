//
//  AdoptFavoriteViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation

class AdoptFavoriteViewModel {
    
    // MARK: - Properties
    let favoritePets = Box([Pet]())
    
    var error: Box<Error?> = Box(nil)
    
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
                
                self.favoritePets.value = favoritePets
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
    
    private func fetchLSFavoritePets() {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let pets = StorageManager.shared.convertLsPetsToPets(from: lsPets)
                
                self.favoritePets.value = pets
                
            case .failure(let error):
                
                self.error.value = error
            }
        }
    }
}
