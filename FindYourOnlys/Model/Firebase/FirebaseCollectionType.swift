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
    
    case sharedArticle
    
    case user
    
    case chatRoom
    
    case message
    
    case friendRequest
}

enum FirebaseFieldType: String {
    
    case id
    
    case userId
    
    case userID
    
    case createdTime
    
    case blockedUsers
    
    case animalId = "animal_id"
}

