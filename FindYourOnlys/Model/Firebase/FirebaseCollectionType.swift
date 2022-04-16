//
//  FirebaseCollectionType.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

enum FirebaseCollectionType: String {
    
    case favoritePet
    
    case article
    
    case user
    
    case chatRoom
    
    case message
}

enum PostType: String, CaseIterable {
    
    case missing = "遺失"
    
    case found = "尋獲"
}

enum PetKind: String, CaseIterable {
    
    case cat = "貓咪"
    
    case dog = "狗狗"
    
    case others = "其他"
}
