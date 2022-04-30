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
    
    var friendRequest: FriendRequest?
    
    init(model: User, result: SearchFriendResult) {
        
        self.user = model
        
        self.searchFriendResult = result
    }
    
    func sendFriendRequest() {
        
        guard
            var friendRequest = friendRequest else { return }

        
        PetSocietyFirebaseManager.shared.sendFriendRequest(user.id, with: &friendRequest) { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
            
        }
        
    }
}
