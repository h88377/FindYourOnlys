//
//  SearchFriendViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import UIKit
import Lottie

class SearchFriendViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = SearchFriendViewModel()
    
    @IBOutlet private weak var searchTextField: ContentInsetTextField! {
        
        didSet {
            
            searchTextField.delegate = self
            
            searchTextField.textColor = .projectTextColor
            
            searchTextField.placeholder = "請輸入電子信箱查詢使用者"
        }
    }
    
    @IBOutlet private weak var errorMessageLabel: UILabel! {
        
        didSet {
            
            errorMessageLabel.isHidden = true
        }
    }
    
    @IBOutlet private weak var userEmailLabel: UILabel! {
        
        didSet {
            
            userEmailLabel.textColor = .projectTextColor
            
            userEmailLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet private weak var animationView: AnimationView! {
        
        didSet {
            
            animationView.loopMode = .loop
            
            animationView.play()
            
            animationView.backgroundColor = .projectBackgroundColor
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.searchViewModel.bind { [weak self] searchViewModel in
            
            guard
                let self = self,
                let searchViewModel = searchViewModel
            else { return }
            
            let storyboard = UIStoryboard.chatSociety
            
            let searchResult = searchViewModel.searchResult
            
            guard
                let friendProfileVC = storyboard.instantiateViewController(
                    withIdentifier: FriendProfileViewController.identifier
                )as? FriendProfileViewController,
                searchResult != .noRelativeEmail
            else {
                
                self.errorMessageLabel.isHidden = false
                
                self.errorMessageLabel.text = SearchFriendResult.noRelativeEmail.rawValue
                
                return
            }
            
            if let user = searchViewModel.user {
                
                self.errorMessageLabel.isHidden = true
                
                friendProfileVC.viewModel = FriendProfileViewModel(model: user, result: searchResult)
                
                friendProfileVC.modalPresentationStyle = .overFullScreen
                
                self.present(friendProfileVC, animated: true)
            }
        }
        
        viewModel.error.bind { [weak self] error in
            
            guard
                let self = self,
                let error = error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
    }
    
    // MARK: - Method
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "搜尋用戶"
    }
}

// MARK: - UITextFieldDelegate

extension SearchFriendViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let userEmail = textField.text else { return }
        
        viewModel.changedUserEmail(with: userEmail)
        
        viewModel.searchUserEmail()
    }
}
