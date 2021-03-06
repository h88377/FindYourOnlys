//
//  FriendRequestHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/8.
//

import UIKit

class FriendRequestHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    @IBOutlet private weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var headerLabel: UILabel! {
        
        didSet {
            
            headerLabel.textColor = .white
            
            headerLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    // MARK: - Methods
    
    func configureView(with text: String) {
        
        headerLabel.text = text
    }
}
