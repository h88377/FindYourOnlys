//
//  RegisterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit
import Lottie

class RegisterViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = RegisterViewModel()
    
    @IBOutlet private weak var animationView: AnimationView! {
        
        didSet {
            
            animationView.loopMode = .loop
            
            animationView.play()
            
            animationView.contentMode = .scaleAspectFit
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        
        didSet {
            
            titleLabel.font = UIFont(name: "Thonburi Bold", size: 30)
            
            titleLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var registerLabel: UILabel! {
        
        didSet {
            
            registerLabel.textColor = .projectTextColor
            
            registerLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        }
    }
    
    @IBOutlet private weak var nickNameTextField: ContentInsetTextField! {
        
        didSet {
            
            nickNameTextField.placeholder = "暱稱"
            
            nickNameTextField.textColor = .projectTextColor
            
            nickNameTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
    
    @IBOutlet private weak var checkPasswordTextField: ContentInsetTextField! {
        
        didSet {
            
            checkPasswordTextField.placeholder = "確認密碼"
            
            checkPasswordTextField.textColor = .projectTextColor
            
            checkPasswordTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            
            checkPasswordTextField.isSecureTextEntry = true
        }
    }
    
    @IBOutlet private weak var errorLabel: UILabel! {
        
        didSet {
            
            errorLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            
            errorLabel.textColor = .red
            
            errorLabel.isHidden = true
        }
    }
    
    @IBOutlet private weak var registerButton: UIButton! {
        
        didSet {
            
            registerButton.setTitle("註冊", for: .normal)
            
            registerButton.setTitleColor(.white, for: .normal)
            
            registerButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            registerButton.backgroundColor = .projectIconColor1
            
            registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
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

        view.backgroundColor = .white
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in

            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                if
                    let authError = error as? AuthError {
                    
                    self.errorLabel.text = authError.errorMessage
                    
                    self.errorLabel.isHidden = false
                    
                } else if
                    let firebaseError = error as? FirebaseError {
                    
                    self.errorLabel.text = firebaseError.errorMessage
                    
                    self.errorLabel.isHidden = false
                }
            }
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.errorLabel.isHidden = true
            
            self.presentingViewController?.dismiss(animated: true)
            
            self.dismissHandler?()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        registerButton.layer.cornerRadius = 15
    }
    
    // MARK: - Method and IBActions
    
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
    
    @IBAction func register(_ sender: UIButton) {
        
        guard
            let nickName = nickNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let checkPassword = checkPasswordTextField.text,
            nickName != "",
            email != "",
            password != "",
            checkPassword != ""
                
        else {
            
            AlertWindowManager.shared.showAlertWindow(at: self, title: "請填寫完整註冊資料喔！")
            
            return
        }
        
        errorLabel.isHidden = password == checkPassword
        
        if password != checkPassword {
            
            errorLabel.text = "密碼與確認密碼不同，請重新輸入"
            
            return
        }
        
        viewModel.register(with: nickName, with: email, with: password)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
}
