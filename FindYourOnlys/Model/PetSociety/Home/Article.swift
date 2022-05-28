//
//  Article.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import FirebaseFirestoreSwift

struct Article: Codable {
    
    var id: String
    
    var userId: String
    
    var likeUserIds: [String]
    
    var createdTime: TimeInterval
    
    var postType: Int?
    
    var city: String
    
    var petKind: String?
    
    var color: String?
    
    var content: String
    
    var imageURLString: String
    
    var comments: [Comment]
    
    init() {
        
        id = ""
        
        userId = UserFirebaseManager.shared.currentUser?.id ?? ""
        
        likeUserIds = []
        
        createdTime = 0
        
        city = ""
        
        petKind = ""
        
        color = ""
        
        content = ""
        
        imageURLString = ""
        
        comments = []
        
    }
}

struct Comment: Codable {
    
    var articleId: String
    
    var userId: String
    
    var content: String
    
    var createdTime: TimeInterval
    
    init() {
        
        articleId = ""
        
        userId = ""
        
        content = ""
        
        createdTime = -1
    }
}

enum PostType: String, CaseIterable {
    
    case missing = "遺失"
    
    case found = "尋獲"
}

enum Sex: String, CaseIterable {
    
    case male = "公"
    
    case female = "母"
}

enum PetKind: String, CaseIterable {
    
    case cat = "貓"
    
    case dog = "狗"
    
    case others = "其他"
}
