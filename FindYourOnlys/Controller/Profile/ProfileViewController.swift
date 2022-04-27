//
//  ProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit
import FirebaseAuth

class ProfileViewController: BaseViewController {

    let viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            if
                let deleteDataError = errorViewModel?.error as? DeleteDataError {
                
                self?.showAlertWindow(title: "異常", message: deleteDataError.errorMessage)
                
            } else if
                
                let deleteAccountError = errorViewModel?.error as? DeleteAccountError {
                
                self?.showAlertWindow(title: "異常", message: deleteAccountError.errorMessage)
                
            }
        }
    }
    
    @IBAction func goToFriendRequest(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.profile
        
        let friendRequestVC = storyboard.instantiateViewController(
            withIdentifier: ProfileFriendRequestViewController.identifier)
        
        navigationController?.pushViewController(friendRequestVC, animated: true)
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        
        viewModel.signOut()
    }
    
    @IBAction func showAuth(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.auth
        
        let authVC = storyboard.instantiateViewController(
            withIdentifier: AuthViewController.identifier)
        
        authVC.modalPresentationStyle = .custom
        
        authVC.transitioningDelegate = self
        
        present(authVC, animated: true)
    }
    
    @IBAction func deleteUser(_ sender: UIButton) {
        
        showDeleteWindow(title: "警告", message: "您將刪除個人帳號，確定要刪除帳號嗎？")
    }
    
    func showDeleteWindow(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            
            self?.viewModel.deleteUser()
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(cancel)
        
        alert.addAction(delete)
        
        present(alert, animated: true)
    }
    
}

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
