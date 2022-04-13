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
    
    let userId: String
    
    let likeUserIds: [String]
    
    let createdTime: TimeInterval
    
    let postType: Int?
    
    let city: String
    
    let petKind: String
    
    let color: String
    
    let content: String
    
    let imageURLStrung: String
    
    let comments: [Comment]
}

struct Comment: Codable {
    
    let userId: String
    
    let content: String
}
