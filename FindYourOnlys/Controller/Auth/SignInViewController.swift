//
//  LoginViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/25.
//

import UIKit
import Lottie

class SignInViewController: BaseViewController {
    
    let viewModel = SignInViewModel()
    
    @IBOutlet weak var animationView: AnimationView! {
        
        didSet {
            
            animationView.loopMode = .loop
            
            animationView.play()
            
            animationView.contentMode = .scaleAspectFit
            
            animationView.backgroundColor = .signInBackGroundColor
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        
        didSet {
            
            titleLabel.font = UIFont(name: "Thonburi Bold", size: 30)
            
            titleLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var welcomeLabel: UILabel! {
        
        didSet {
            
            welcomeLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            
            welcomeLabel.textColor = .projectTextColor
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
            
            passwordTextField.textColor = .projectTextColor
            
            passwordTextField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
    @IBOutlet weak var signInButton: UIButton! {
        
        didSet {
            
            signInButton.setTitle("登入", for: .normal)
            
            signInButton.setTitleColor(.white, for: .normal)
            
            signInButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            signInButton.backgroundColor = .projectIconColor1
            
            signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        }
    }
    
    var dismissHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .signInBackGroundColor

        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            print(errorViewModel?.error.localizedDescription)
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            self?.dismiss(animated: true)
            
            self?.dismissHandler?()
        }
        
        viewModel.startLoadingHandler = { [weak self] in

            guard
                let self = self else { return }
            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.startLoading(at: self.view)
            }
        }
        
        viewModel.stopLoadingHandler = {

            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.stopLoading()
            }
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
