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
        
        postType = -1
        
        city = ""
        
        petKind = ""
        
        color = ""
        
        content = ""
        
        imageURLString = ""
        
        comments = []
        
    }
}

