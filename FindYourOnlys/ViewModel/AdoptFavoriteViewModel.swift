//
//  AdoptFavoriteViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit.UIImage

class AdoptFavoriteViewModel {
    
    let favoritePetViewModels = Box([FavoritePetViewModel]())
    
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

    
    private func convertLsPetsToViewModels(from lsPets: [LSPet]) -> [FavoritePetViewModel] {
        
//        let pets = convertLsPetsToPets(from: lsPets)
        
        var viewModels = [FavoritePetViewModel]()
        
        for lsPet in lsPets {
            
            let viewModel = FavoritePetViewModel(model: lsPet)
            
            viewModels.append(viewModel)
        }
        
        return viewModels
    }
    
    private func setPets(with lsPets: [LSPet]) {
        
        favoritePetViewModels.value = convertLsPetsToViewModels(from: lsPets)
    }
    
    func convertLsPetsToPets(from lsPets: ([LSPet])) -> [Pet] {
        
        var pets = [Pet]()
        
        for lsPet in lsPets {
            
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
            pets.append(pet)
        }
        
        return pets
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



