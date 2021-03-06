//
//  FriendProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import Foundation
import UIKit

class FriendProfileViewController: BaseViewController {
    
    // MARK: - Properties
    
    var viewModel: FriendProfileViewModel?
    
    @IBOutlet private weak var userImageView: ProportionSizeImageView!
    
    @IBOutlet private weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
            
            nickNameLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var emailTitleLabel: UILabel! {
        
        didSet {
            
            emailTitleLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var emailLabel: UILabel! {
        
        didSet {
            
            emailLabel.font = UIFont.systemFont(ofSize: 14)
            
            emailLabel.textColor = .systemGray
        }
    }
    
    @IBOutlet private weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var requestButton: UIButton! {
        
        didSet {
            
            requestButton.setTitleColor(.white, for: .normal)
            
            requestButton.setTitleColor(.projectIconColor2, for: .disabled)
            
            requestButton.backgroundColor = .projectIconColor1
            
            requestButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet private weak var cancelButton: UIButton! {
        
        didSet {
            
            cancelButton.setTitleColor(.white, for: .normal)
            
            cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            cancelButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectBackgroundColor2
        }
    }
        
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        viewModel?.error.bind { [weak self] error in
            
            guard
                let self = self,
                let error = error
            else { return }
          
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
        
        viewModel?.dismissHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.dismiss(animated: true)
        }
        
        updateSearchedUserInfo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        baseView.layer.cornerRadius = 15
        
        requestButton.layer.cornerRadius = 15
        
        cancelButton.layer.cornerRadius = 15
    }
    
    // MARK: - Methods and IBActions
    
    func updateSearchedUserInfo() {
        
        guard let viewModel = viewModel else { return }
        
        let result = viewModel.searchFriendResult
        
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
            
        case .receivedRequest:
            
            requestButton.isEnabled = false
            
        case .sentRequest:
            
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
