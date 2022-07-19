//
//  PetSocietyFilterViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import Foundation

class FindPetSocietyFilterViewModel {
    
    // MARK: - Properties
    
    let findPetSocietyFilterCategory = FindPetSocietyFilterCategory.allCases
    
    var findPetSocietyFilterCondition = FindPetSocietyFilterCondition()
    
    var isValidCondition: Bool {
        
        let conditions = [
            findPetSocietyFilterCondition.city,
            findPetSocietyFilterCondition.petKind,
            findPetSocietyFilterCondition.color]
        
        let isValidCondition = !conditions
            .map { $0 == "" }
            .contains(true) &&
        findPetSocietyFilterCondition.postType != -1
        
        return isValidCondition
    }
    
    // MARK: - Methods
    
    func cityChanged(with city: String) {
        
        findPetSocietyFilterCondition.city = city
    }
    
    func petKindChanged(with petKind: String) {
        
        findPetSocietyFilterCondition.petKind = petKind
    }
    
    func postTypeChanged(with postType: String) {
        
        findPetSocietyFilterCondition.postType = postType == PostType.missing.rawValue
        ? 0
        : 1
    }
    
    func colorChanged(with color: String) {
        
        findPetSocietyFilterCondition.color = color
    }
}
