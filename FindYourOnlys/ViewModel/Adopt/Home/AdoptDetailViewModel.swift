//
//  AdoptDetailViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

// Should not import UIKit
import UIKit

class AdoptDetailViewModel {
    
    // MARK: - Properties
    let adoptDetailContentCategory = AdoptDetailContentCategory.allCases
    
    let favoritePetViewModels = Box([PetViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var petViewModel = Box(
        PetViewModel(
            model: Pet(
                id: 0, location: "", kind: "",
                sex: "", bodyType: "", color: "",
                age: "", sterilization: "", bacterin: "",
                foundPlace: "", status: "", remark: "",
                openDate: "", closedDate: "", updatedDate: "",
                createdDate: "", photoURLString: "", address: "",
                telephone: "", variety: "", shelterName: ""
            )
        )
    )
    
    var checkFavoriateButtonHandler: (() -> Void)?
    
    var toggleFavoriteButtonHandler: (() -> Void)?
    
    var makePhoneCallHandler: (() -> Void)?
    
    var shareHandler: (() -> Void)?
    
    private var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    private var favoritePetsFromLS = [LSPet]()
    
    // MARK: - Methods
    func fetchFavoritePet() {
        
        if didSignIn {
            
            fetchFavoritePetFromFB()
            
        } else {
            
            fetchFavoritePetFromLS()
        }
        
    }
    
    func addPetInFavorite() {
        
        if didSignIn {
            
            addFavoritePetInFB()
            
        } else {
            
            addFavoritePetInLS()
        }
    }
    
    func removeFavoritePet() {
        
        if didSignIn {
            
            removeFavoriteFromFB()
            
        } else {
            
            removeFavoriteFromLS()
        }
    }
    
    func checkFavoriteButton() {
        
        checkFavoriateButtonHandler?()
    }
    
    func toggleFavoriteButton() {
        
        toggleFavoriteButtonHandler?()
    }
    
    func makePhoneCall() {
        
        makePhoneCallHandler?()
    }
    
    func share() {
        
        shareHandler?()
    }
    
    private func fetchFavoritePetFromFB() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
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
                
                self.checkFavoriateButtonHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func fetchFavoritePetFromLS() {
        
        StorageManager.shared.fetchPet { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let lsPets):
                
                let pets = StorageManager.shared.convertLsPetsToPets(from: lsPets)
                
                PetProvider.shared.setPets(petViewModels: self.favoritePetViewModels, with: pets)
                
                self.favoritePetsFromLS = lsPets
                
                self.checkFavoriateButtonHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    private func addFavoritePetInFB() {
        
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
    
    private func removeFavoriteFromLS() {
        
        let removeId = petViewModel.value.pet.id
        
        for favoritePetFromLS in favoritePetsFromLS where favoritePetFromLS.id == removeId {
            
            StorageManager.shared.removePetfromFavorite(lsPet: favoritePetFromLS) { [weak self] result in
                
                if case .failure(let error) = result {
                  
                    self?.errorViewModel.value = ErrorViewModel(model: error)
                }
            }
        }
    }
    
    private func removeFavoriteFromFB() {
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: petViewModel.value) { [weak self] result in
            
            if case .failure(let error) = result {
              
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
