//
//  RegisterViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import Foundation

class RegisterViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    func register(with nickName: String, with email: String, with password: String) {
        
        UserFirebaseManager.shared.register(with: nickName, with: email, with: password) { [weak self] error in
            
            guard
                let self = self,
                error == nil
            
            else {
                
                self?.errorViewModel.value = ErrorViewModel(model: error!)
                
                return
            }
            
            self.dismissHandler?()
            
        }
    }
}
