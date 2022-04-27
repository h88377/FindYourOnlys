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
    
    var hasSetPointOrigin = false
    
    var pointOrigin: CGPoint?
    
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
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !hasSetPointOrigin {
            
            hasSetPointOrigin = true
            
            pointOrigin = self.view.frame.origin
        }
        
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
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
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
