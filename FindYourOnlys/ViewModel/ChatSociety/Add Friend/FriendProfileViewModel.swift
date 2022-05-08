//
//  FriendProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import Foundation

class FriendProfileViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var user: User
    
    var searchFriendResult: SearchFriendResult
    
    var friendRequest = FriendRequest(requestUserId: "", requestedUserId: "", createdTime: -1)
    
    var dismissHandler: (() -> Void)?
    
    init(model: User, result: SearchFriendResult) {
        
        self.user = model
        
        self.searchFriendResult = result
    }
    
    func sendFriendRequest() {
        
        PetSocietyFirebaseManager.shared.sendFriendRequest(user.id, with: &friendRequest) { [weak self] result in
            
            switch result {
                
            case .success(_):
                
                self?.dismissHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
