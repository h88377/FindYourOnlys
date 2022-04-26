//
//  ProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/26.
//

import Foundation

class ProfileViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    func signOut() {
        
        UserFirebaseManager.shared.signOut { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
            
            print("Sign out successfully.")
        }
    }
}
