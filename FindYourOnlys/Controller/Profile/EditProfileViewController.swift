//
//  EditProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/30.
//

import UIKit

class EditProfileViewController: BaseViewController {
    
    let viewModel = EditProfileViewModel()
    
    override var isHiddenTabBar: Bool { return true }

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
    

    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        let barButtonItem = UIBarButtonItem(title: "刪除帳號", style: .done, target: self, action: #selector(deleteAccount))
        
        barButtonItem.tintColor = .red
        
        navigationItem.rightBarButtonItem = barButtonItem
    }

    @objc func deleteAccount(sender: UIBarButtonItem) {
        
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
