//
//  LoginViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit
import Lottie

class SignInViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = SignInViewModel()
    
    @IBOutlet private weak var animationView: AnimationView! {
        
        didSet {
            
            animationView.loopMode = .loop
            
            animationView.play()
            
            animationView.contentMode = .scaleAspectFit
            
            animationView.backgroundColor = .signInBackGroundColor
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        
        didSet {
            
            titleLabel.font = UIFont(name: "Thonburi Bold", size: 30)
            
            titleLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var welcomeLabel: UILabel! {
        
        didSet {
            
            welcomeLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
            
            welcomeLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var emailTextField: ContentInsetTextField! {
        
        didSet {
            
            emailTextField.placeholder = "電子信箱"
            
            emailTextField.textColor = .projectTextColor
            
            emailTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @IBOutlet private weak var passwordTextField: ContentInsetTextField! {
        
        didSet {
            
            passwordTextField.placeholder = "密碼"
            
            passwordTextField.textColor = .projectTextColor
            
            passwordTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBOutlet private weak var signInButton: UIButton! {
        
        didSet {
            
            signInButton.setTitle("登入", for: .normal)
            
            signInButton.setTitleColor(.white, for: .normal)
            
            signInButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            signInButton.backgroundColor = .projectIconColor1
            
            signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        }
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        
        didSet {
            
            errorLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            
            errorLabel.textColor = .red
            
            errorLabel.isHidden = true
        }
    }
    
    @IBOutlet private weak var dismissButton: UIButton! {
        
        didSet {
            
            dismissButton.tintColor = .projectTextColor
        }
    }
    
    var dismissHandler: (() -> Void)?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .signInBackGroundColor
        
        viewModel.signInState.bind { signInState in
            
            switch signInState {
                
            case .success:
                
                self.errorLabel.isHidden = true
                
                self.dismiss(animated: true)
                
                self.dismissHandler?()
                
            case .failure(let error):
                
                if
                    let authError = error as? AuthError {
                    
                    self.errorLabel.text = authError.errorMessage
                    
                    self.errorLabel.isHidden = false
                    
                } else if
                    let firebaseError = error as? FirebaseError {
                    
                    self.errorLabel.text = firebaseError.errorMessage
                    
                    self.errorLabel.isHidden = false
                }
                
            case .none:
                
                return
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signInButton.layer.cornerRadius = 15
        
    }
    
    // MARK: - Methods and IBActions
    
    override func setupLoadingViewHandler() {
        
        viewModel.startLoadingHandler = { [weak self] in

            guard
                let self = self else { return }
            
            self.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.stopLoading()
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email != "",
            password != ""
        
        else {
            
            AlertWindowManager.shared.showAlertWindow(at: self, title: "請填寫完整資訊登入喔！")
            
            return
        }
                     
        viewModel.signIn(withEmail: email, password: password)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
}
