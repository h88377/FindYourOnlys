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
    
    var startLoadingHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    func register(with nickName: String, with email: String, with password: String) {
        
        startLoadingHandler?()
        
        UserFirebaseManager.shared.register(with: nickName, with: email, with: password) { [weak self] result in
            
            switch result {
                
            case .success(let registeredUserId):
                
                UserFirebaseManager.shared.fetchUser { [weak self] result in

                    switch result {

                    case .success(let users):

                        for user in users where user.id == registeredUserId {

                            UserFirebaseManager.shared.currentUser = user
                            
                            self?.stopLoadingHandler?()
                            
                            self?.dismissHandler?()
                            
                            break
                        }

                    case .failure(let error):

                        self?.errorViewModel.value = ErrorViewModel(model: error)
                        
                        self?.stopLoadingHandler?()
                    }
                }
                
            case .failure(let error):
                
                self?.errorViewModel.value = ErrorViewModel(model: error)
                
                self?.stopLoadingHandler?()
            }
        }
    }
}
