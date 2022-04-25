//
//  AuthViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit
import AuthenticationServices

class AuthViewController: UIViewController {
    
    let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { errorViewModel in
            
            print(errorViewModel?.error)
        }
    }
    
    @IBAction func signInWithApple(_ sender: UIButton) {
        
        performSignIn()
    }
    
    func performSignIn() {
        
        let request = UserFirebaseManager.shared.createAppleIdRequest()
        
        let authorizationViewController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationViewController.delegate = self
        
        authorizationViewController.presentationContextProvider = self
        
        authorizationViewController.performRequests()
    }
    
    
    
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization) {
            
            viewModel.didCompleteWithAuthorization(with: authorization)
        }
    
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
    }
}
