//
//  LoginViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit

class SignInViewController: BaseViewController {
    
    let viewModel = SignInViewModel()
    
    @IBOutlet weak var emailTextField: ContentInsetTextField! {
        
        didSet {
            
            emailTextField.placeholder = "電子信箱"
        }
    }
    
    @IBOutlet weak var passwordTextField: ContentInsetTextField! {
        
        didSet {
            
            passwordTextField.placeholder = "密碼"
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        
        didSet {
            
            signInButton.setTitle("登入", for: .normal)
            
            signInButton.tintColor = .black
            
            signInButton.backgroundColor = .projectPlaceHolderColor
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
        
        signInButton.layer.cornerRadius = 15
        
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email != "",
            password != ""
        
        else {
            
            showAlertWindow(title: "請填寫完整資訊登入喔！", message: "")
            
            return
        }
                
                
        viewModel.signIn(withEmail: email, password: password)
    }
    
}
