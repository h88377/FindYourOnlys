//
//  SearchFriendResult.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import Foundation

enum SearchFriendResult: String {
    
    case currentUser = "無法將自己的帳號加入好友"
    
    case friend = "已加入好友"
    
    case noRelativeId = "查無此 User ID 的使用者"
    
    case sentRequest = "已傳送好友邀請"
    
    case receivedRequest = "待接受好友邀請"
    
    case limitedUser = "封鎖名單使用者"
    
    case normalUser = "發送好友邀請吧"
}
