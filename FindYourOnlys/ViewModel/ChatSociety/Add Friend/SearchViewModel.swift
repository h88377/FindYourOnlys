//
//  SearchViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/27.
//

import Foundation

class SearchViewModel {
    
    var user: User?
    
    var searchResult: SearchFriendResult
    
    init(user: User? = nil, searchResult: SearchFriendResult) {
        
        self.user = user
        
        self.searchResult = searchResult
    }
}
