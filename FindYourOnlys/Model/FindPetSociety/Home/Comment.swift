//
//  Comment.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import Foundation

struct Comment: Codable {
    
    var articleId: String
    
    var userId: String
    
    var content: String
    
    var createdTime: TimeInterval
}
