//
//  PetSocietyFilterViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import Foundation

class FindPetSocietyFilterViewModel {
    
    let findPetSocietyFilterCategory = FindPetSocietyFilterCategory.allCases
    
    var findPetSocietyFilterCondition = FindPetSocietyFilterCondition()
    
    var isValidCondition: Bool {
        
        let conditionsArray = [
            findPetSocietyFilterCondition.city,
            findPetSocietyFilterCondition.petKind,
            findPetSocietyFilterCondition.color
        ]
        
        let isValidCondition = !conditionsArray.map { $0 == "" }
            .contains(true) && findPetSocietyFilterCondition.postType != -1
        
        return isValidCondition
    }
   
}

extension FindPetSocietyFilterViewModel {
    
    func cityChanged(with city: String) {
        
        findPetSocietyFilterCondition.city = city
    }
    
    func petKindChanged(with petKind: String) {
        
        findPetSocietyFilterCondition.petKind = petKind
    }
    
    func postTypeChanged(with postType: String) {
        
        if postType == PostType.missing.rawValue {
            
            findPetSocietyFilterCondition.postType = 0
            
        } else {
            
            findPetSocietyFilterCondition.postType = 1
        }
    }
    
    func colorChanged(with color: String) {
        
        findPetSocietyFilterCondition.color = color
    }
    
}
