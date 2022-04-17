//
//  FriendRequest.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import Foundation

struct FriendRequest: Codable {
    
    let requestUserId: String
    
    let reqeustedUserId: String
    
    let createdTime: TimeInterval
}
