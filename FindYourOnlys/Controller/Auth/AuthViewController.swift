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
            
            print(errorViewModel?.error.localizedDescription)
        }
    }
    
    
    
    func performSignIn() {
        
        let request = UserFirebaseManager.shared.createAppleIdRequest()
        
        let authorizationViewController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationViewController.delegate = self
        
        authorizationViewController.presentationContextProvider = self
        
        authorizationViewController.performRequests()
    }
    
    @IBAction func signInWithApple(_ sender: UIButton) {
        
        performSignIn()
    }
    
    @IBAction func register(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.auth
        
        let registerVC = storyboard.instantiateViewController(withIdentifier: RegisterViewController.identifier)
        
        present(registerVC, animated: true)
        
    }
    
    @IBAction func signInWithFirebase(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.auth
        
        let signInVC = storyboard.instantiateViewController(withIdentifier: SignInViewController.identifier)
        
        present(signInVC, animated: true)
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
