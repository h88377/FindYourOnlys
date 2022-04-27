//
//  Comment.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import Foundation

struct Comment: Codable {
    
    let articleId: String
    
    let userId: String
    
    let content: String
    
    let createdTime: TimeInterval
    
    let senderId: String
}
