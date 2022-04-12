//
//  AdoptDetailViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit.UIImage
import UIKit

class AdoptDetailViewModel {
    
    private enum FavoriteType: String {
        
        case add = "Add"
        
        case remove = "Remove"
    }
    
    var didLogin: Bool = true
    
    let adoptDetailDescription = AdoptDetailDescription.allCases
    
    let favoriteLSPetViewModels = Box([FavoriteLSPetViewModel]())
    
    let favoritePetViewModels = Box([PetViewModel]())
    
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
    
    func makePhoneCall(_ viewController: UIViewController) {
        
        let phoneNumber = petViewModel.value.pet.telephone
        
        guard
            let url = URL(string: "tel://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url)
                
        else {
            
            let alert = UIAlertController(title: "號碼錯誤", message: "電話號碼格式錯誤，麻煩使用手機撥號", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(action)
            
            viewController.present(alert, animated: true)
            
            return
        }
        
        if #available(iOS 10, *) {
            
            UIApplication.shared.open(url)
            
        } else {
            
            UIApplication.shared.openURL(url)
        }
    }
    
    // MARK: - Local Storage functions
    func fetchFavoritePetFromLS(completion: (Error?) -> Void ) {
        
        StorageManager.shared.fetchPet { result in
            
            switch result {
                
            case .success(let lsPets):
                
                self.setPets(with: lsPets)
                
                self.favoritePetsFromLS = lsPets
                
                completion(nil)
                
            case .failure(let error):
                
                completion(error)
            }
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
    
    // MARK: - Firebase functions
    func fetchFavoriteFromFB(completion: @escaping (Error?) -> Void) {
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { result in
            
            switch result {
                
            case .success(let pets):
                
                self.setPets(pets)
                
                completion(nil)
                
            case .failure(let error):
                
                completion(error)
            }
        }
    }
    
    func addToFavoriteInFB(completion: @escaping (Error?) -> Void) {
        
        FavoritePetFirebaseManager.shared.saveFavoritePet("123", with: petViewModel.value) { error in
            
            completion(error)
        }
    }
    
    func removeFavoriteFromFB() {
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: petViewModel.value)
    }
    
    
    // MARK: - Common functions
    // Use for AdoptDetailVC viewDidLoad
    func checkFavoriteButton(with favoriteButton: UIButton) {
        
        favoriteButton.setTitle(FavoriteType.add.rawValue, for: .normal)
        
        if !didLogin {
            
            for favoriteLSPetViewModel in favoriteLSPetViewModels.value {
                
                if favoriteLSPetViewModel.lsPet.id == petViewModel.value.pet.id {
                    
                    favoriteButton.setTitle(FavoriteType.remove.rawValue, for: .normal)
                    
                    break
                }
            }
            
        } else {
            
            for favoritePetViewModel in favoritePetViewModels.value {
                
                if favoritePetViewModel.pet.id == petViewModel.value.pet.id {
                    
                    favoriteButton.setTitle(FavoriteType.remove.rawValue, for: .normal)
                    
                    break
                }
            }
        }
        
    }
    
    // Use for when user tap add/remove favorite
    func toggleFavoriteButton(with favoriteButton: UIButton, completion: @escaping (Error?) -> Void) {
        
        // Save data
        if favoriteButton.currentTitle == FavoriteType.add.rawValue {
            
            if !didLogin {
                
                addToFavoriteInLS()
                
            } else {
                
                addToFavoriteInFB { error in
                    
                    completion(error)
                }
            }
            
        // Remove data
        } else {
            
            if !didLogin {
                
                removeFavoriteFromLS()
                
            } else {
                
                removeFavoriteFromFB()
            }
        }
        
        favoriteButton.setTitle(
            favoriteButton.currentTitle == FavoriteType.add.rawValue
            ? FavoriteType.remove.rawValue
            : FavoriteType.add.rawValue, for: .normal
        )
    }
    
    
    
    
    // MARK: - Private functions
    // Local storage
    private func convertLsPetsToViewModels(from lsPets: [LSPet]) -> [FavoriteLSPetViewModel] {
        
        //        let pets = convertLsPetsToPets(from: lsPets)
        
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
    
    // Firebase
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
