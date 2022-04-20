//
//  Shelter.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import Foundation

struct Shelter {
    
    let title: String
    
    let address: String
    
    var petCounts: [PetCount]
    
}

struct PetCount {
    
    let petKind: String
    
    var count: Int
}
