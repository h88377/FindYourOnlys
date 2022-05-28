//
//  SignInViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/26.
//

import Foundation

class SignInViewModel {
    
    // MARK: - Properties
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var dismissHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    // MARK: - Method
    
    func signIn(withEmail email: String, password: String) {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.signIn(withEmail: email, password: password) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let registeredUserId):
                
                UserFirebaseManager.shared.fetchUser { result in

                    switch result {

                    case .success(let users):

                        for user in users where user.id == registeredUserId {

                            UserFirebaseManager.shared.currentUser = user
                            
                            self.dismissHandler?()
                            
                            break
                        }

                    case .failure(let error):

                        self.errorViewModel.value = ErrorViewModel(model: error)
                    }
                    self.stopLoadingHandler?()
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
        }
    }
}
