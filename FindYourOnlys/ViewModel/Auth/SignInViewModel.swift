//
//  SignInViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/26.
//

import Foundation

class SignInViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    func signIn(withEmail email: String, password: String) {
        
        UserFirebaseManager.shared.signIn(withEmail: email, password: password) { [weak self] error in
            
            guard
                error == nil
                    
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
            
            self?.dismissHandler?()
        }
    }
    
}
