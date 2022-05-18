//
//  AdoptFilterViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/22.
//

import Foundation

class AdoptFilterViewModel {
    
    let adoptFilterCategory = AdoptFilterCategory.allCases
    
    var adoptFilterCondition = AdoptFilterCondition()
    
    var isValidCondition: Bool {
        
        let conditionsArray = [adoptFilterCondition.city, adoptFilterCondition.petKind, adoptFilterCondition.sex, adoptFilterCondition.color]
        
        let isValidCondition = conditionsArray.map { $0 == "" }.contains(false)
        
        return isValidCondition
    }
}

extension AdoptFilterViewModel {
    
    func cityChanged(with city: String) {
        
        adoptFilterCondition.city = city
    }
    
    func petKindChanged(with petKind: String) {
        
        adoptFilterCondition.petKind = petKind
    }
    
    func sexChanged(with sex: String) {
        
        adoptFilterCondition.sex = sex
    }
    
    func colorChanged(with color: String) {
        
        adoptFilterCondition.color = color
    }
}
