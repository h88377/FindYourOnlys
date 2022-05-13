//
//  ChatRoomCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit

class ChatRoomUserMessageCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel! {
        
        didSet {
            
            contentLabel.textColor = .projectTextColor
            
            contentLabel.backgroundColor = .projectBackgroundColor2
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView! {
        
        didSet {
            
            contentImageView.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel! {
        
        didSet {
            
            timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            
            timeLabel.textColor = .projectPlaceHolderColor
        }
    }
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    func configureCell(with viewModel: MessageViewModel, friend: User) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        if currentUser.id == viewModel.message.senderId {
            
            timeLabel.textAlignment = .right
            
//            contentLabel.textAlignment = .right
            
            friendImageView.isHidden = true
            
            userImageView.isHidden = !friendImageView.isHidden
            
        } else {
            
            timeLabel.textAlignment = .left
            
//            contentLabel.textAlignment = .left
           
            friendImageView.isHidden = false
            
            userImageView.isHidden = !friendImageView.isHidden
        }
        
        contentLabel.textAlignment = .left
        
        friendImageView.loadImage(friend.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        timeLabel.text = viewModel.message.createdTime.formatedTime
        
        contentLabel.isHidden = true
        
        contentImageView.isHidden = true
        
        if
            let content = viewModel.message.content,
            content != "" {
            
            contentLabel.text = content
            
            contentLabel.isHidden = false
            
            imageViewHeightConstraint.constant = 0
            
        } else if
            let imageURLString = viewModel.message.contentImageURLString {
            
            contentImageView.loadImage(imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
            
            contentImageView.isHidden = false
            
            imageViewHeightConstraint.constant = 150
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.height / 2

        friendImageView.layer.cornerRadius = userImageView.frame.height / 2
        
        contentLabel.layer.cornerRadius = 12
        
        contentLabel.clipsToBounds = true
        
        contentImageView.layer.cornerRadius = 12
    }
    
}
