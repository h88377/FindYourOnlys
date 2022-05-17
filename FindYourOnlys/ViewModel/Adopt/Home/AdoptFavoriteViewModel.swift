//
//  AdoptFavoriteViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation

class AdoptFavoriteViewModel {
    
    // MARK: - Properties
    
    private var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    let favoritePetViewModels = Box([PetViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    // MARK: - Methods
    
    func fetchFavoritePets() {
        
        if didSignIn {
            
            fetchFavoritePetsFromFB()
            
        } else {
            
            fetchFavoritePetsFromLS()
        }
    }
    
    private func fetchFavoritePetsFromFB() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser
                
        else { return }
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                var favoritePets: [Pet] = []
                
                for pet in pets where pet.userID == currentUser.id {
                    
                    favoritePets.append(pet)
                }
                
                PetProvider.shared.setPets(petViewModels: self.favoritePetViewModels, with: favoritePets)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func fetchFavoritePetsFromLS() {
        
        StorageManager.shared.fetchPet { result in
            
            switch result {
                
            case .success(let lsPets):
                
                let pets = StorageManager.shared.convertLsPetsToPets(from: lsPets)
                
                PetProvider.shared.setPets(petViewModels: favoritePetViewModels, with: pets)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
