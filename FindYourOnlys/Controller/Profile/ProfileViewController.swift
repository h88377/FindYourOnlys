//
//  ProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func goToFriendRequest(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.profile
        
        let friendRequestVC = storyboard.instantiateViewController(withIdentifier: ProfileFriendRequestViewController.identifier)
        
        navigationController?.pushViewController(friendRequestVC, animated: true)
    }
    

}
