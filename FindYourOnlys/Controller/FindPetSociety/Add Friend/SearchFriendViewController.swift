//
//  SearchFriendViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import UIKit

class SearchFriendViewController: BaseViewController {
    
    @IBOutlet weak var searchTextField: ContentInsetTextField! {
        
        didSet {
            
            searchTextField.delegate = self
            
            searchTextField.textColor = .projectTextColor
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.system(.search),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            searchTextField.rightView = button
            
            searchTextField.rightViewMode = .always
            
            searchTextField.placeholder = "請輸入 User email 查詢使用者"
        }
    }
    
    @IBOutlet weak var errorMessageLabel: UILabel! {
        
        didSet {
            
            errorMessageLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var userIdLabel: UILabel! {
        
        didSet {
            
            userIdLabel.textColor = .projectTextColor
            
            userIdLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    let viewModel = SearchFriendViewModel()
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "搜尋好友"
    }
}

// MARK: - UITextFieldDelegate
extension SearchFriendViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard
//            let userId = textField.text else { return }
        let userEmail = textField.text else { return }
        
//        viewModel.searchUserId(with: userId) { [weak self] result in
            
        viewModel.searchUserEmail(with: userEmail) { [weak self] result in
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let searchResult):
                
                DispatchQueue.main.async {
                    
                    let storyboard = UIStoryboard.profile
                    
                    guard
                        let friendProfileVC = storyboard.instantiateViewController(
                            withIdentifier: FriendProfileViewController.identifier)
                            as? FriendProfileViewController,
                        searchResult != .noRelativeEmail
                            
                    else {
                        
                        self.errorMessageLabel.isHidden = false
                        
                        self.errorMessageLabel.text = SearchFriendResult.noRelativeEmail.rawValue
                        
                        return
                    }
                    
                    self.errorMessageLabel.isHidden = true
                    
                    friendProfileVC.viewModel = FriendProfileViewModel(model: self.viewModel.user, result: searchResult)
                    
                    friendProfileVC.modalPresentationStyle = .overFullScreen
                    
                    self.present(friendProfileVC, animated: true)
                }
                
            case.failure(let error):
                
                print(error)
            }
        }
    }
}
