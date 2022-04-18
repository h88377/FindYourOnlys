//
//  AddFriendViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import Foundation

class AddFriendViewModel {
    
    var searchUserIdHander: (() -> Void)?
    
    func searchUserId() {
        
        searchUserIdHander?()
    }
    
}
