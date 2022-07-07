//
//  AuthViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import Foundation
import AuthenticationServices
import AVFoundation

enum AuthState {
    
    case none
    
    case success
    
    case failure(Error)
}

class AuthViewModel {
    
    // MARK: - Properties
    
    var authState: Box<AuthState> = Box(.none)
    
    // MARK: - Method
    
    func didCompleteWithAuthorization(with authorization: ASAuthorization) {
        
        UserFirebaseManager.shared.signInWithAppleAuthorization(with: authorization) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success:
                
                self.authState.value = .success
                
            case .failure(let error):
                
                self.authState.value = .failure(error)
            }
        }
    }
}
