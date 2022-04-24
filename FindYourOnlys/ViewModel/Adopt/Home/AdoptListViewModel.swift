//
//  AdoptListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

class AdoptListViewModel {
    
    let petViewModels = Box([PetViewModel]())
    
//    var filterConditionViewModel: Box<AdoptFilterCondition?> = Box(nil)
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var currentPage = 1
    
    var stopIndicatorHandler: (() -> Void)?
    
    func fetchPet(with condition: AdoptFilterCondition? = nil) {
        
        PetProvider.shared.fetchPet(with: condition) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.setPets(pets)
                
            case .failure(let error):
                
                self?.errorViewModel = Box(ErrorViewModel(model: error))
            }
        }
        
    }
    
    func fetchPet(with condition: AdoptFilterCondition? = nil, paging: Int) {
        
        PetProvider.shared.fetchPet(with: condition, paging: currentPage + 1) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.appendPets(pets)
                
                self?.stopIndicatorHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel = Box(ErrorViewModel(model: error))
            }
        }
        
    }
    
//    func fetchPet(with condition: AdoptFilterCondition) {
//        
//        PetProvider.shared.fetchPet(with: condition) { [weak self] result in
//            
//            switch result {
//                
//            case .success(let pets):
//                
//                self?.setPets(pets)
//                
//            case .failure(let error):
//                
//                self?.errorViewModel = Box(ErrorViewModel(model: error))
//            }
//        }
//        
//    }
    
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
    
    private func appendPets(_ pets: [Pet]) {
        
        let appendedPetViewModels = convertPetsToViewModels(from: pets)
        
        petViewModels.value += appendedPetViewModels
        
        currentPage += 1
    }
}
