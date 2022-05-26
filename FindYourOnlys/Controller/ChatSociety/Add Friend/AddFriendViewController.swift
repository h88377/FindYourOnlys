//
//  AddFriendViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/17.
//

import UIKit

class AddFriendViewController: BaseViewController {
    
    // MARK: - Properties
    
    @IBOutlet private weak var searchLabel: UILabel! {
        
        didSet {
            
            searchLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var qrCodeLabel: UILabel! {
        
        didSet {
            
            qrCodeLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var myCodeLabel: UILabel! {
        
        didSet {
            
            myCodeLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var searchButton: UIButton! {
        
        didSet {
            
            searchButton.imageView?.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var qrCodeButton: UIButton! {
        
        didSet {
            
            qrCodeButton.imageView?.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var myQRCodeImageView: UIImageView! {
        
        didSet {
            
            myQRCodeImageView.tintColor = .projectIconColor1
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - Method and IBAction
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "新增好友"
    }
    
    @IBAction func searchUserId(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.chatSociety
        
        let searchFriendVC = storyboard.instantiateViewController(withIdentifier: SearchFriendViewController.identifier)
        
        navigationController?.pushViewController(searchFriendVC, animated: true)
    }
    
    @IBAction func searchQRCode(_ sender: UIButton) {
    }
}
