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
    
    func didCompleteWithAuthorization(with authorization: ASAuthorization) {
        
        UserFirebaseManager.shared.didCompleteWithAuthorization(with: authorization) { [weak self] error in
            
            guard
                let self = self,
                let error = error
                    
            else { return }
            
            self.errorViewModel.value = ErrorViewModel(model: error)
        }
    }
}
