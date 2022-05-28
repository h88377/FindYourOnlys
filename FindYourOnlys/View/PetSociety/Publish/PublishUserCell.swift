//
//  PublishUserCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishUserCell: BasePublishCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var userNickName: UILabel! {
        
        didSet {
            
            userNickName.textColor = .projectTextColor
            
            userNickName.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    // MARK: - Methods
    
    override func layoutCell(article: Article? = nil) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userNickName.text = currentUser.nickName
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.makeRound()
    }
}
