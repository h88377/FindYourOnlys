//
//  PetSocietyFilterViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import Foundation

class PetSocietyFilterViewModel {
    
    let petSocietyFilterCategory = PetSocietyFilterCategory.allCases
    
    var petSocietyFilterCondition = PetSocietyFilterCondition(
        postType: -1,
        city: "",
        petKind: "",
        color: ""
    )
}

extension PetSocietyFilterViewModel {
    
    func cityChanged(with city: String) {
        
        petSocietyFilterCondition.city = city
    }
    
    func petKindChanged(with petKind: String) {
        
        petSocietyFilterCondition.petKind = petKind
    }
    
    func postTypeChanged(with postType: String) {
        
        if postType == PostType.missing.rawValue {
            
            petSocietyFilterCondition.postType = 0
            
        } else {
            
            petSocietyFilterCondition.postType = 1
        }
    }
    
    func colorChanged(with color: String) {
        
        petSocietyFilterCondition.color = color
    }
    
}
