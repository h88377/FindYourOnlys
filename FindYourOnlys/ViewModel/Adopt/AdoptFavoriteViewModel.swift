//
//  AdoptFavoriteViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation

class AdoptFavoriteViewModel {
    
    let favoriteLSPetViewModels = Box([FavoriteLSPetViewModel]())
    
    let favoritePetViewModels = Box([PetViewModel]())
    
    func fetchFavoritePetFromLS(completion: (Error?) -> Void ) {
        
        StorageManager.shared.fetchPet { result in
            
            switch result {
                
            case .success(let lsPets):
                
                self.setPets(with: lsPets)
                
            case .failure(let error):
                
                completion(error)
            }
        }
    }
    
    func fetchFavoritePetFromFB(completion: @escaping (Error?) -> Void ) {
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.setPets(pets)
            
            case .failure(let error):
                
                completion(error)
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
            variety: lsPet.variety
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

