//
//  LoginViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit

class SignInViewController: UIViewController {
    
    let viewModel = SignInViewModel()
    
    @IBOutlet weak var emailTextField: ContentInsetTextField!
    
    @IBOutlet weak var passwordTextField: ContentInsetTextField!
    
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
    
    @IBAction func signIn(_ sender: UIButton) {
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text,
            email != "",
            password != ""
        
        else { return }
                
                
        viewModel.signIn(withEmail: email, password: password)
    }
    
}
