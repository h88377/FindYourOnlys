//
//  ChatRoom.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import Foundation

struct ChatRoom: Codable {
    
    var id: String
    
    var userIds: [String]
    
    var createdTime: TimeInterval
}
