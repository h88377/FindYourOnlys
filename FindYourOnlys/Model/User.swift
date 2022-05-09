//
//  User.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import Foundation

struct User: Codable {
    
    var id: String
    
    var nickName: String
    
    var email: String
    
    var imageURLString: String
    
    var friends: [String]
    
    var blockedUsers: [String]
}
