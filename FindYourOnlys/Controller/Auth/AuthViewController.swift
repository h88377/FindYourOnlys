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
    
    @IBOutlet weak var indicatorView: UIView! {
        
        didSet {
            
            indicatorView.backgroundColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var signInWithAppleButton: ASAuthorizationAppleIDButton! {
        
        didSet {
            
            signInWithAppleButton.addTarget(self, action: #selector(signInWithApple), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var registerButton: UIButton! {
        
        didSet {
            
            registerButton.backgroundColor = .projectIconColor1
            
            registerButton.setTitle("註冊", for: .normal)
            
            registerButton.setTitleColor(.white, for: .normal)
            
            registerButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        
        didSet {
            
            signInButton.backgroundColor = .projectIconColor1
            
            signInButton.setTitle("登入", for: .normal)
            
            signInButton.setTitleColor(.white, for: .normal)
            
            signInButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        }
    }
    
    @IBOutlet weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectBackgroundColor2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                errorViewModel?.error == nil else {
                    
                    if
                        let authError = errorViewModel?.error as? AuthError {
                        
                        self?.showAlertWindow(title: "異常", message: authError.errorMessage)
                    }
                    
                    return
                }
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            print("Sign in with Apple successfully.")
            
            self?.dismiss(animated: true)
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
        
        let viewController = storyboard.instantiateViewController(withIdentifier: RegisterViewController.identifier)
        
        guard
            let registerVC = viewController as? RegisterViewController else { return }
        
        present(registerVC, animated: true)
        
        registerVC.dismissHandler = { [weak self] in
            
            self?.dismiss(animated: true)
        }
    }
    
    @IBAction func signInWithFirebase(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.auth
        
        let viewController = storyboard.instantiateViewController(withIdentifier: SignInViewController.identifier)
        
        guard
            let signInVC = viewController as? SignInViewController else { return }
        
        present(signInVC, animated: true)
        
        signInVC.dismissHandler = { [weak self] in
            
            self?.dismiss(animated: true)
        }
    }
    
    @IBAction func goToPolicy(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.auth
        
        guard
            let policyVC = storyboard.instantiateViewController(
                withIdentifier: PolicyViewController.identifier)
                as? PolicyViewController
        
        else { return }
        
        policyVC.viewModel = PolicyViewModel(urlString: "https://pages.flycricket.io/findyouronlys/privacy.html")
        
        present(policyVC, animated: true)
    }
    
    @IBAction func goToEula(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.auth
        
        guard
            let policyVC = storyboard.instantiateViewController(
                withIdentifier: PolicyViewController.identifier)
                as? PolicyViewController
        
        else { return }
        
        policyVC.viewModel = PolicyViewModel(
            urlString: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
        )
        
        present(policyVC, animated: true)
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
