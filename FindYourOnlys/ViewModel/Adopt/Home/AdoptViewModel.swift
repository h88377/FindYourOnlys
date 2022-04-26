//
//  AdoptViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/26.
//

import Foundation

class AdoptViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    func fetchCurrentUser() {
        
        guard
            let initialUserId = UserFirebaseManager.shared.initialUserId
                
        else { return }
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                for user in users where user.id == initialUserId {
                    
                    UserFirebaseManager.shared.currentFBUserInfo = user
                    
                    break
                }
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
