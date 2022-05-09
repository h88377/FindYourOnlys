//
//  FriendProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import Foundation
import UIKit

class FriendProfileViewController: BaseViewController {
    
    var viewModel: FriendProfileViewModel?
    
    @IBOutlet weak var userImageView: ProportionSizeImageView!
    
    @IBOutlet weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            
            nickNameLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var emailTitleLabel: UILabel! {
        
        didSet {
            
            emailTitleLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var emailLabel: UILabel! {
        
        didSet {
            
            emailLabel.font = UIFont.systemFont(ofSize: 14)
            
            emailLabel.textColor = .systemGray
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var requestButton: UIButton! {
        
        didSet {
            
            requestButton.setTitleColor(.white, for: .normal)
            
            requestButton.setTitleColor(.projectIconColor2, for: .disabled)
            
            requestButton.backgroundColor = .projectIconColor1
            
            requestButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton! {
        
        didSet {
            
            cancelButton.setTitleColor(.white, for: .normal)
            
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            cancelButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectBackgroundColor2
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        guard
            let viewModel = viewModel else { return }
        
        updateSearchedUserInfo(with: viewModel, result: viewModel.searchFriendResult)
        
        viewModel.errorViewModel.bind(listener: { [weak self] errorViewModel in
            
            if
                let error = errorViewModel?.error {
                
                DispatchQueue.main.async {
                    self?.showAlertWindow(title: "異常", message: "\(error)")
                }
            }
        })
        
        viewModel.dismissHandler = { [weak self] in
            
            self?.dismiss(animated: true)
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        
        baseView.layer.cornerRadius = 15
        
        requestButton.layer.cornerRadius = 15
        
        cancelButton.layer.cornerRadius = 15
    }
    
    func updateSearchedUserInfo(with viewModel: FriendProfileViewModel, result: SearchFriendResult) {
        
        let user = viewModel.user
        
        userImageView.loadImage(user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        nickNameLabel.text = "暱稱: \(user.nickName)"
        
        emailLabel.text = user.email
        
        statusLabel.text = result.rawValue
        
        switch result {
            
        case .currentUser:
            
            requestButton.isEnabled = false
            
        case .friend:
            
            requestButton.isEnabled = false
            
        case .normalUser:
            
            requestButton.isEnabled = true
            
        case .noRelativeEmail:
            
            requestButton.isEnabled = false
            
        case .sentRequest:
            
            requestButton.isEnabled = false
            
        case .receivedRequest:
            
            requestButton.isEnabled = false
            
        case .blockedUser:
            
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
