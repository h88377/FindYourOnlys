//
//  AuthViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import Foundation
import AuthenticationServices

class AuthViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    func didCompleteWithAuthorization(with authorization: ASAuthorization) {
        
        UserFirebaseManager.shared.didCompleteWithAuthorization(with: authorization) { [weak self] error in
            
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
