//
//  AdoptListViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation

class AdoptListViewModel {
    
    let petViewModels = Box([PetViewModel]())
    
    var filterConditionViewModel = Box(
        AdoptFilterCondition(
        city: "",
        petKind: "",
        sex: "",
        color: ""
        )
    )
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var currentPage = 0
    
    var stopIndicatorHandler: (() -> Void)?
    
    var startIndicatorHandler: (() -> Void)?
    
    var resetPetHandler: (() -> Void)?
    
    var noMorePetHandler: (() -> Void)?
    
    func fetchPet() {
        
        // Need to change header loader
        startIndicatorHandler?()
        
        PetProvider.shared.fetchPet(with: filterConditionViewModel.value, paging: currentPage + 1) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                if pets.count > 0 {
                    
                    self?.appendPets(pets)
                    
                    self?.stopIndicatorHandler?()
                    
                    self?.currentPage += 1
                    
                } else {
                    
                    self?.noMorePetHandler?()
                    
                    self?.stopIndicatorHandler?()
                    
                    return
                }
                
                
            case .failure(let error):
                
                self?.errorViewModel = Box(ErrorViewModel(model: error))
            }
        }
        
    }
    
    func resetFetchPet() {
        
        // Need to change header loader
        startIndicatorHandler?()
        
        resetPetHandler?()
        
        PetProvider.shared.fetchPet(with: filterConditionViewModel.value, paging: currentPage + 1) { [weak self] result in
            
            switch result {
                
            case .success(let pets):
                
                self?.setPets(pets)
                
                self?.stopIndicatorHandler?()
                
                self?.currentPage += 1
                
            case .failure(let error):
                
                self?.errorViewModel = Box(ErrorViewModel(model: error))
            }
        }
        
    }
    
    func resetFilterCondition() {
        
        filterConditionViewModel.value = AdoptFilterCondition(
            city: "",
            petKind: "",
            sex: "",
            color: ""
            )
        
        currentPage = 0
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
    
    private func appendPets(_ pets: [Pet]) {
        
        let appendedPetViewModels = convertPetsToViewModels(from: pets)
        
        petViewModels.value += appendedPetViewModels
    }
}
