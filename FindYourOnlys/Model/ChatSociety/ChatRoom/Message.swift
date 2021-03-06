//
//  Thread.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import Foundation

struct Message: Codable {
    
    var chatRoomId: String
    
    var senderId: String
    
    var content: String?
    
    var contentImageURLString: String?
    
    var createdTime: TimeInterval
    
    init() {
        
        self.chatRoomId = ""
        
        self.senderId = ""
        
        self.content = ""
        
        self.contentImageURLString = ""
        
        self.createdTime = -1
    }
}
