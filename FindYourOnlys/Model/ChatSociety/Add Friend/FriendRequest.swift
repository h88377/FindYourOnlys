//
//  FriendRequest.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import Foundation

struct FriendRequestList {
    
    let type: FriendRequestType
    
    var users: [User]
}

struct FriendRequest: Codable {
    
    var requestUserId: String
    
    var requestedUserId: String
    
    var createdTime: TimeInterval
}

