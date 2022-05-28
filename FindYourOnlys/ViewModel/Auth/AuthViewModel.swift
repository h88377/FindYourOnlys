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
    
    // MARK: - Properties
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    // MARK: - Method
    
    func didCompleteWithAuthorization(with authorization: ASAuthorization) {
        
        UserFirebaseManager.shared.didCompleteWithAuthorization(with: authorization) { [weak self] result in
            
            guard
                let self = self else { return }
            switch result {
                
            case .success:
                
                self.dismissHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
        }
    }
}
