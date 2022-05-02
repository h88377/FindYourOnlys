//
//  EditProfileViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import Foundation

class EditProfileViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    func deleteUser() {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.deleteAuthUser { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                self?.stopLoadingHandler?()
                
                return
            }
            
            print("Delete user successfully.")
            
            UserFirebaseManager.shared.currentUser = nil
            
            self?.stopLoadingHandler?()
            
            self?.dismissHandler?()
        }
    }
}
