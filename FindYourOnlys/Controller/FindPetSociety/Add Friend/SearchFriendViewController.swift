//
//  SearchFriendViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import UIKit
import SwiftUI

class SearchFriendViewController: BaseViewController {
    
    @IBOutlet weak var searchTextField: ContentInsetTextField! {
        
        didSet {
            
            searchTextField.delegate = self
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.system(.search),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            searchTextField.rightView = button
            
            searchTextField.rightViewMode = .always
            
            searchTextField.placeholder = "請輸入 User ID 查詢使用者"
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.isHidden = true
        }
    }
    
    @IBOutlet weak var userNickNameLabel: UILabel! {
        
        didSet {
            
            userNickNameLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var requestButton: UIButton! {
        
        didSet {
            
            requestButton.isHidden = true
        }
    }
    
    @IBOutlet weak var errorMessageLabel: UILabel! {
        
        didSet {
            
            errorMessageLabel.isHidden = true
        }
    }
    
    let viewModel = SearchFriendViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func sendFriendRequest(_ sender: UIButton) {
        
        viewModel.sendFriendRequest { error in
            
            if error != nil { print(error)
                
            } else {
                
                sender.isEnabled = false
                
                sender.setTitle(SearchFriendResult.sentRequest.rawValue, for: .disabled)
            }
        }
    }
    
    func toggleSearchedUserInfo(isExisted: Bool) {
        
        userImageView.isHidden = !isExisted
        
        userNickNameLabel.isHidden = !isExisted
        
        statusLabel.isHidden = !isExisted
        
        requestButton.isHidden = !isExisted
        
        requestButton.isEnabled = isExisted
        
        errorMessageLabel.isHidden = isExisted
    }
    
    func updateSearchedUserInfo(with viewModel: SearchFriendViewModel, result: SearchFriendResult) {
        
        let user = viewModel.user
        
        userImageView.loadImage(user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userNickNameLabel.text = user.nickName
        
        statusLabel.text = result.rawValue
        
        errorMessageLabel.text = result.rawValue
        
        switch result {
            
        case .currentUser:
            
            requestButton.isHidden = true
            
        case .friend:
            
            requestButton.isHidden = true
            
        case .normalUser:
            
            requestButton.isHidden = false
            
        case .noRelativeId:
            
            requestButton.isHidden = true
            
        case .sentRequest:
            
            requestButton.isEnabled = false
            
            requestButton.setTitleColor(.systemGray2, for: .disabled)
            
        case .receivedRequest:
            
            requestButton.isEnabled = false
            
            requestButton.setTitleColor(.systemGray2, for: .disabled)
            
        case .limitedUser:
            
            requestButton.isEnabled = false
            
            requestButton.setTitleColor(.systemGray2, for: .disabled)
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension SearchFriendViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard
            let userId = textField.text else { return }
        
        viewModel.searchUserId(with: userId) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let searchResult):
                
                DispatchQueue.main.async {
                    
                    switch searchResult {
                        
                    case .currentUser:
                        
                        self.toggleSearchedUserInfo(isExisted: true)
                        
                        self.updateSearchedUserInfo(with: self.viewModel, result: .currentUser)
                        
                    case .friend:
                        
                        self.toggleSearchedUserInfo(isExisted: true)
                        
                        self.updateSearchedUserInfo(with: self.viewModel, result: .friend)
                        
                    case .normalUser:
                        
                        self.toggleSearchedUserInfo(isExisted: true)
                        
                        self.updateSearchedUserInfo(with: self.viewModel, result: .normalUser)
                        
                    case .noRelativeId:
                        
                        self.toggleSearchedUserInfo(isExisted: false)
                        
                        self.updateSearchedUserInfo(with: self.viewModel, result: .noRelativeId)
                        
                    case .sentRequest:
                        
                        self.toggleSearchedUserInfo(isExisted: true)
                        
                        self.updateSearchedUserInfo(with: self.viewModel, result: .sentRequest)
                        
                    case .receivedRequest:
                        
                        self.toggleSearchedUserInfo(isExisted: true)
                        
                        self.updateSearchedUserInfo(with: self.viewModel, result: .receivedRequest)
                        
                    case .limitedUser:
                        
                        self.toggleSearchedUserInfo(isExisted: true)
                        
                        self.updateSearchedUserInfo(with: self.viewModel, result: .limitedUser)
                    }
                }
                
            case.failure(let error):
                
                print(error)
            }
        }
    }
    
}
