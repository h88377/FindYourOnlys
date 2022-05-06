//
//  AdoptFavoriteViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation

class AdoptFavoriteViewModel {
    
    // Combine LS and FB into one viewModel when refactor
    let favoriteLSPetViewModels = Box([FavoriteLSPetViewModel]())
    
    let favoritePetViewModels = Box([PetViewModel]())
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    func fetchFavoritePetFromLS() {
        
        StorageManager.shared.fetchPet { result in
            
            switch result {
                
            case .success(let lsPets):
                
                self.setPets(with: lsPets)
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func fetchFavoritePetFromFB() {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                var favoritePets: [Pet] = []
                
                for pet in pets where pet.userID == currentUser.id {
                    
                    favoritePets.append(pet)
                }
                
                self?.setPets(favoritePets)
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
    
    
    private func convertLsPetsToViewModels(from lsPets: [LSPet]) -> [FavoriteLSPetViewModel] {
        
        var viewModels = [FavoriteLSPetViewModel]()
        
        for lsPet in lsPets {
            
            let viewModel = FavoriteLSPetViewModel(model: lsPet)
            
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
    
    private func setPets(with lsPets: [LSPet]) {
        
        favoriteLSPetViewModels.value = convertLsPetsToViewModels(from: lsPets)
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
        
        favoritePetViewModels.value = convertPetsToViewModels(from: pets)
    }
    
    func convertLsPetToPet(from lsPet: (LSPet)) -> Pet {
        
        let pet = Pet(
            id: Int(lsPet.id), location: lsPet.location, kind: lsPet.kind,
            sex: lsPet.sex, bodyType: lsPet.bodyType, color: lsPet.color,
            age: lsPet.age, sterilization: lsPet.sterilization, bacterin: lsPet.bacterin,
            foundPlace: lsPet.foundPlace, status: lsPet.status, remark: lsPet.remark,
            openDate: lsPet.openDate, closedDate: lsPet.closedDate,
            updatedDate: lsPet.updatedDate, createdDate: lsPet.createdDate,
            photoURLString: lsPet.photoURLString, address: lsPet.address, telephone: lsPet.telephone,
            variety: lsPet.variety, shelterName: lsPet.shelterName
        )
        return pet
    }
    
}

//    func convertLsPetsToPets(from lsPets: ([LSPet])) -> [Pet] {
//
//        var pets = [Pet]()
//
//        for lsPet in lsPets {
//
//            let pet = Pet(
//                id: Int(lsPet.id), location: lsPet.location, kind: lsPet.kind,
//                sex: lsPet.sex, bodyType: lsPet.bodyType, color: lsPet.color,
//                age: lsPet.age, sterilization: lsPet.sterilization, bacterin: lsPet.bacterin,
//                foundPlace: lsPet.foundPlace, status: lsPet.status, remark: lsPet.remark,
//                openDate: lsPet.openDate, closedDate: lsPet.closedDate,
//                updatedDate: lsPet.updatedDate, createdDate: lsPet.createdDate,
//                photoURLString: lsPet.photoURLString, address: lsPet.address, telephone: lsPet.telephone,
//                variety: lsPet.variety
//            )
//            pets.append(pet)
//        }
//
//        return pets
//    }

