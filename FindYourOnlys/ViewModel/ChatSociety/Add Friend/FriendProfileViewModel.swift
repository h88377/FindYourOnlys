//
//  FriendProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import Foundation

class FriendProfileViewModel {
    
    // MARK: - Properties
    
    var user: User
    
    var searchFriendResult: SearchFriendResult
    
    init(model: User, result: SearchFriendResult) {
        
        self.user = model
        
        self.searchFriendResult = result
    }
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func sendFriendRequest() {
        
        PetSocietyFirebaseManager.shared.sendFriendRequest(user.id) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success:
                
                self.dismissHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
