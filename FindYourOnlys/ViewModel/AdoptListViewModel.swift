//
//  AdoptListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit.UIImage

class AdoptListViewModel {
    
    let petViewModels = Box([PetViewModel]())
    
    func fetchPet(completion: @escaping (Error?) -> Void) {
        
        PetProvider.shared.fetchPet { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.setPets(pets)
                
            case .failure(let error):
                
                completion(error)
            }
        }
        
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
        
        petViewModels.value = convertPetsToViewModels(from: pets)
    }
}
