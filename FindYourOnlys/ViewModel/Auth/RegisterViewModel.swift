//
//  RegisterViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import Foundation

class RegisterViewModel {
    
    // MARK: - Properties
    
    var registerState: Box<AuthState> = Box(.none)
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    // MARK: - Method
    
    func register(with nickName: String, with email: String, with password: String) {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.register(with: nickName, with: email, with: password) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let registeredUserId):
                
                UserFirebaseManager.shared.fetchUser { result in

                    switch result {

                    case .success(let users):

                        for user in users where user.id == registeredUserId {

                            UserFirebaseManager.shared.currentUser = user
                            
                            self.registerState.value = .success
                            
                            break
                        }

                    case .failure(let error):
                        
                        self.registerState.value = .failure(error)
                    }
                    
                    self.stopLoadingHandler?()
                }
                
            case .failure(let error):
                
                self.registerState.value = .failure(error)
                
                self.stopLoadingHandler?()
            }
        }
    }
}
