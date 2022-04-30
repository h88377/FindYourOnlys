//
//  EditProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import Foundation

class EditProfileViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    func deleteUser() {
        
        UserFirebaseManager.shared.deleteAuthUser { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
            
            print("Delete user successfully.")
            
            UserFirebaseManager.shared.currentUser = nil
        }
    }
}
