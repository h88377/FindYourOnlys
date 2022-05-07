//
//  AuthViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import Foundation
import AuthenticationServices
import AVFoundation

class AuthViewModel {
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    func didCompleteWithAuthorization(with authorization: ASAuthorization) {
        
        UserFirebaseManager.shared.didCompleteWithAuthorization(with: authorization) { [weak self] result in
            
            switch result {
                
            case .success(_):
                
                self?.dismissHandler?()
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
