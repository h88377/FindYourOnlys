//
//  Article.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation
import FirebaseFirestoreSwift

struct Article: Identifiable, Codable {
    
    @DocumentID var id: String?
    
    var userId: String
    
    var likeUserIds: [String]
    
    var createdTime: TimeInterval
    
    var postType: Int?
    
    var city: String
    
    var petKind: String
    
    var color: String
    
    var content: String
    
    var imageURLString: String
    
    var comments: [Comment]
}

struct Comment: Codable {
    
    let userId: String
    
    let content: String
}
