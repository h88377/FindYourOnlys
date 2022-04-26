//
//  ProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit

class ProfileViewController: UIViewController {

    let viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            print(errorViewModel?.error.localizedDescription)
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
    
}

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
