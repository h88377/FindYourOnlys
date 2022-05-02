//
//  RegisterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit

class RegisterViewController: BaseViewController {
    
    let viewModel = RegisterViewModel()
    
    @IBOutlet weak var registerLabel: UILabel! {
        
        didSet {
            
            registerLabel.textColor = .projectTextColor
            
            registerLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
        }
    }
    
    @IBOutlet weak var nickNameTextField: ContentInsetTextField! {
        
        didSet {
            
            nickNameTextField.placeholder = "暱稱"
            
            nickNameTextField.textColor = .projectTextColor
            
            nickNameTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @IBOutlet weak var emailTextField: ContentInsetTextField! {
        
        didSet {
            
            emailTextField.placeholder = "電子信箱"
            
            emailTextField.textColor = .projectTextColor
            
            emailTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @IBOutlet weak var passwordTextField: ContentInsetTextField! {
        
        didSet {
            
            passwordTextField.placeholder = "密碼"
            
//            passwordTextField.textContentType = .newPassword
            passwordTextField.textColor = .projectTextColor
            
            passwordTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @IBOutlet weak var registerButton: UIButton! {
        
        didSet {
            
            registerButton.setTitle("註冊", for: .normal)
            
            registerButton.setTitleColor(.white, for: .normal)
            
            registerButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            registerButton.backgroundColor = .projectIconColor1
            
            registerButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.errorViewModel.bind { errorViewModel in

            guard
                errorViewModel?.error != nil else { return }
            
            print(errorViewModel?.error.localizedDescription)
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            self?.dismiss(animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        registerButton.layer.cornerRadius = 15
    }
    
    @IBAction func register(_ sender: UIButton) {
        
        guard
            let nickName = nickNameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            nickName != "",
            email != "",
            password != ""
                
        else {
            
            showAlertWindow(title: "請填寫完整註冊資料喔！", message: "")
            
            return
        }
        
        viewModel.register(with: nickName, with: email, with: password)
    }
    
}
