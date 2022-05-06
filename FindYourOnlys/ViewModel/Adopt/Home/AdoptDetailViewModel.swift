//
//  AdoptDetailViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

// Should not import UIKit
import UIKit

class AdoptDetailViewModel {
    
    private enum FavoriteType: String {
        
        case add = "Add"
        
        case remove = "Remove"
    }
    
    var didSignIn: Bool {
        
        return UserFirebaseManager.shared.currentUser != nil
    }
    
    let adoptDetailContentCategory = AdoptDetailContentCategory.allCases
    
    let favoriteLSPetViewModels = Box([FavoriteLSPetViewModel]())
    
    let favoritePetViewModels = Box([PetViewModel]())
    
    var favoritePetsFromLS = [LSPet]()
    
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
        
        for favoritePetFromLS in favoritePetsFromLS where favoritePetFromLS.id == removeId {
            
            StorageManager.shared.removePetfromFavorite(lsPet: favoritePetFromLS)
        }
    }
    
    // MARK: - Firebase functions
    func fetchFavoriteFromFB(completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.fetchFavoritePets { result in
            
            switch result {
                
            case .success(let pets):
                
                var favoritePets: [Pet] = []
                
                for pet in pets where pet.userID == currentUser.id {
                    
                    favoritePets.append(pet)
                }
                
                self.setPets(favoritePets)
                
                completion(nil)
                
            case .failure(let error):
                
                completion(error)
            }
        }
    }
    
    func addToFavoriteInFB(completion: @escaping (Error?) -> Void) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        FavoritePetFirebaseManager.shared.saveFavoritePet(currentUser.id, with: petViewModel.value) { error in
            
            completion(error)
        }
    }
    
    func removeFavoriteFromFB() {
        
        FavoritePetFirebaseManager.shared.removeFavoritePet(with: petViewModel.value)
    }
    
    
    // MARK: - Common functions
    // Use for AdoptDetailVC viewDidLoad
    func checkFavoriteButton(with favoriteButton: UIButton) {
        
        favoriteButton.setImage(UIImage.system(.addToFavorite), for: .normal)
        
        if !didSignIn {
            
            for favoriteLSPetViewModel in favoriteLSPetViewModels.value where favoriteLSPetViewModel.lsPet.id == petViewModel.value.pet.id {
                
                favoriteButton.setImage(UIImage.system(.removeFromFavorite), for: .normal)
            }
            
        } else {
            
            for favoritePetViewModel in favoritePetViewModels.value where favoritePetViewModel.pet.id == petViewModel.value.pet.id {
                
                favoriteButton.setImage(UIImage.system(.removeFromFavorite), for: .normal)
            }
        }
    }
    
    // Use for when user tap add/remove favorite
    func toggleFavoriteButton(with favoriteButton: UIButton, completion: @escaping (Error?) -> Void) {
        
        // Save data
        if favoriteButton.currentImage == UIImage.system(.addToFavorite)
        {
            
            if !didSignIn {
                
                addToFavoriteInLS()
                
            } else {
                
                addToFavoriteInFB { error in
                    
                    completion(error)
                }
            }
            
        // Remove data
        } else {
            
            if !didSignIn {
                
                removeFavoriteFromLS()
                
            } else {
                
                removeFavoriteFromFB()
            }
        }
        
        favoriteButton.setImage(
            favoriteButton.currentImage == UIImage.system(.addToFavorite)
            ? UIImage.system(.removeFromFavorite)
            : UIImage.system(.addToFavorite), for: .normal
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
