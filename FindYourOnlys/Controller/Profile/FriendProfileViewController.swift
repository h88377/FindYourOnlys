//
//  FriendProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import Foundation
import UIKit

class FriendProfileViewController: UIViewController {
    
    var viewModel: FriendProfileViewModel?
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        }
    }
    
    @IBOutlet weak var idLabel: UILabel! {
        
        didSet {
            
            idLabel.font = UIFont.systemFont(ofSize: 14)
            
            idLabel.textColor = .systemGray
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var requestButton: UIButton! {
        
        didSet {
            
            requestButton.setTitleColor(.black, for: .normal)
            
            requestButton.setTitleColor(.systemGray, for: .disabled)
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        
        didSet {
            
            cancelButton.setTitleColor(.black, for: .normal)
        }
    }
    
    @IBOutlet weak var baseView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupFriend()
        
        guard
            let viewModel = viewModel else { return }

        
        updateSearchedUserInfo(with: viewModel, result: viewModel.searchFriendResult)
        
        viewModel.errorViewModel.bind(listener: { errorViewModel in
            
            guard
                errorViewModel?.error == nil
            
            else {
                
                print(errorViewModel?.error.localizedDescription)
                
                return
            }
        })
        
        viewModel.dismissHandler = { [weak self] in
            
            self?.dismiss(animated: true)
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        
        baseView.layer.cornerRadius = 15
        
        requestButton.layer.cornerRadius = 15
        
        cancelButton.layer.cornerRadius = 15
    }
    
//    func setupFriend() {
//
//        guard
//            let friend = viewModel?.user else { return }
//
//        userImageView.loadImage(friend.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
//
//        nickNameLabel.text = friend.nickName
//
//        idLabel.text = friend.id
//    }
    
    func updateSearchedUserInfo(with viewModel: FriendProfileViewModel, result: SearchFriendResult) {
        
        let user = viewModel.user
        
        userImageView.loadImage(user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        nickNameLabel.text = "暱稱: \(user.nickName)"
        
        idLabel.text = user.id
        
        statusLabel.text = result.rawValue
        
        switch result {
            
        case .currentUser:
            
            requestButton.isEnabled = false
            
        case .friend:
            
            requestButton.isEnabled = false
            
        case .normalUser:
            
            requestButton.isEnabled = true
            
        case .noRelativeId:
            
            requestButton.isEnabled = false
            
        case .sentRequest:
            
            requestButton.isEnabled = false
            
        case .receivedRequest:
            
            requestButton.isEnabled = false
            
        case .limitedUser:
            
            requestButton.isEnabled = false
        }
    }
    @IBAction func sendFriendRequest(_ sender: UIButton) {
        
        viewModel?.sendFriendRequest()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        
        dismiss(animated: true)
    }
}
