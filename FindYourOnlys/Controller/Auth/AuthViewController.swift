//
//  AuthViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit
import AuthenticationServices

class AuthViewController: BaseModalViewController {
    
    let viewModel = AuthViewModel()
    
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var signInWithAppleButton: ASAuthorizationAppleIDButton! {
        
        didSet {
            
            signInWithAppleButton.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var registerButton: UIButton! {
        
        didSet {
            
            registerButton.backgroundColor = .white
            
            registerButton.setTitle("註冊", for: .normal)
            
            registerButton.tintColor = .black
            
            registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        
        didSet {
            
            signInButton.backgroundColor = .white
            
            signInButton.setTitle("登入", for: .normal)
            
            signInButton.tintColor = .black
            
            signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            print(errorViewModel?.error.localizedDescription)
        }
        
        viewModel.dismissHandler = {
            
            print("Sign in with Apple successfully.")
        }
         
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
        registerButton.layer.cornerRadius = 15
        
        signInButton.layer.cornerRadius = 15
        
        indicatorView.layer.cornerRadius = 5
        
        signInWithAppleButton.cornerRadius = 15
    }
    
    func performSignIn() {
        
        let request = UserFirebaseManager.shared.createAppleIdRequest()
        
        let authorizationViewController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationViewController.delegate = self
        
        authorizationViewController.presentationContextProvider = self
        
        authorizationViewController.performRequests()
    }
    
    @objc func signInWithApple(_ sender: UIButton) {
        
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
