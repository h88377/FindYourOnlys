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
            
            animationView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var welcomeLabel: UILabel! {
        
        didSet {
            
            welcomeLabel.font = UIFont.systemFont(ofSize: 30, weight: .medium)
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        configureAnimationView()
        
        view.backgroundColor = .signInBackGroundColor

        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            print(errorViewModel?.error.localizedDescription)
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            self?.dismiss(animated: true)
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
    
    func configureAnimationView() {
        
        let animationView = AnimationView(name: LottieName.ladyCat.rawValue)
        
        animationView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        
        animationView.contentMode = .scaleAspectFill
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate(
            [
                animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                animationView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 30),
                
                animationView.bottomAnchor.constraint(equalTo: emailTextField.topAnchor, constant: -40),
                
                animationView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1),
                
                animationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
            ]
        )
        
        animationView.play()
        
        animationView.loopMode = .loop
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
