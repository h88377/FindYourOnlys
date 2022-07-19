//
//  AdoptViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/26.
//

import Foundation

class AdoptViewModel {
    
    // MARK: - Properties
    
    var error: Box<Error?> = Box(nil)
    
    var adoptFilterCondition = AdoptFilterCondition()
    
    // MARK: - Methods
    
    func fetchCurrentUser() {
        
        guard let initialUserId = UserFirebaseManager.shared.initialUser?.uid else { return }
        
        UserFirebaseManager.shared.fetchUser { [weak self] result in
            
            switch result {
                
            case .success(let users):
                
                for user in users where user.id == initialUserId {
                    
                    UserFirebaseManager.shared.currentUser = user
                    
                    break
                }
                
            case .failure(let error):
                
                self?.error.value = error
            }
        }
    }
}
