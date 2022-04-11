//
//  AdoptDetailViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit.UIImage

class AdoptDetailViewModel {
    
    private enum FavoriteType: String {
        
        case add = "Add"
        
        case remove = "Remove"
    }
    
    var isLogin: Bool = false
    
    let adoptDetailDescription = AdoptDetailDescription.allCases
    
    let favoritePetViewModels = Box([FavoritePetViewModel]())
    
    var favoritePetsFromLS = [LSPet]()
    
    var petViewModel = Box(
        PetViewModel(
            model: Pet(
                id: 0, location: "", kind: "",
                sex: "", bodyType: "", color: "",
                age: "", sterilization: "", bacterin: "",
                foundPlace: "", status: "", remark: "",
                openDate: "", closedDate: "", updatedDate: "",
                createdDate: "", photoURLString: "", address: "",
                telephone: "", variety: ""
            )
        )
    )
    
    func makePhoneCall() {
        
        let phoneNumber = petViewModel.value.pet.telephone
        
        guard
            let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url)
                
        else { return }
        
        if #available(iOS 10, *) {
            
            UIApplication.shared.open(url)
            
        } else {
            
            UIApplication.shared.openURL(url)
        }
    }
    
    func addToFavoriteInLS() {
        
        StorageManager.shared.savePetInFavorite(with: petViewModel.value)
    }
    
    func removeFavoriteFromLS() {
        
        let removeId = petViewModel.value.pet.id
        
        for favoritePetFromLS in favoritePetsFromLS {
            
            if favoritePetFromLS.id == removeId {
                
                StorageManager.shared.removePetfromFavorite(lsPet: favoritePetFromLS)
                
                break
            }
        }
    }
    
    func checkFavoriteButton(with favoriteButton: UIButton) {
        
        favoriteButton.setTitle(FavoriteType.add.rawValue, for: .normal)
        
        for favoritePetViewModel in favoritePetViewModels.value {
            
            if favoritePetViewModel.lsPet.id == petViewModel.value.pet.id {
                
                favoriteButton.setTitle(FavoriteType.remove.rawValue, for: .normal)
                
                break
            }
        }
        
    }
    
    func toggleFavoriteButton(with favoriteButton: UIButton) {
        
        if favoriteButton.currentTitle == FavoriteType.add.rawValue {
            
            addToFavoriteInLS()
            
        } else {
            
            removeFavoriteFromLS()
        }
        
        favoriteButton.setTitle(
            favoriteButton.currentTitle == FavoriteType.add.rawValue
            ? FavoriteType.remove.rawValue
            : FavoriteType.add.rawValue, for: .normal
        )
    }
    
    func fetchFavoritePetFromLS(completion: (Error?) -> Void ) {
        
        StorageManager.shared.fetchPet { result in
            
            switch result {
                
            case .success(let lsPets):
                
                self.setPets(with: lsPets)
                self.favoritePetsFromLS = lsPets
                
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
    
}


//private func convertLsPetsToPets(from lsPets: ([LSPet])) -> [Pet] {
//    
//    var pets = [Pet]()
//    
//    for lsPet in lsPets {
//        
//        let pet = Pet(
//            id: Int(lsPet.id), location: lsPet.location, kind: lsPet.kind,
//            sex: lsPet.sex, bodyType: lsPet.bodyType, color: lsPet.color,
//            age: lsPet.age, sterilization: lsPet.sterilization, bacterin: lsPet.bacterin,
//            foundPlace: lsPet.foundPlace, status: lsPet.status, remark: lsPet.remark,
//            openDate: lsPet.openDate, closedDate: lsPet.closedDate,
//            updatedDate: lsPet.updatedDate, createdDate: lsPet.createdDate,
//            photoURLString: lsPet.photoURLString, address: lsPet.address, telephone: lsPet.telephone,
//            variety: lsPet.variety
//        )
//        pets.append(pet)
//    }
//    
//    return pets
//}
