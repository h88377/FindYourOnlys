//
//  FirebaseCollectionType.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import Foundation

enum FirebaseCollectionType: String {
    
    case favoritePet
    
    case article
    
    case user
    
    case chatRoom
    
    case message
    
    case friendRequest
}

enum PostType: String, CaseIterable {
    
    case missing = "遺失"
    
    case found = "尋獲"
}

enum PetKind: String, CaseIterable {
    
    case cat = "貓咪"
    
    case dog = "狗狗"
    
    case others = "其他"
}


enum SearchFriendResult: String {
    
    case friend = "已加入好友"
    
    case noRelativeId = "查無此 User ID 的使用者"
    
    case sentRequest = "已傳送好友邀請"
    
    case receivedRequest = "待接受好友邀請"
    
    case limitedUser = "封鎖名單使用者"
}
