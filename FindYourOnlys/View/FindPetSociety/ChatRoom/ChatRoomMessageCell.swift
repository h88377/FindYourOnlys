//
//  ChatRoomCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit

class ChatRoomMessageCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel! {
        
        didSet {
            
            contentLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var contentImageView: UIImageView! {
        
        didSet {
            
            contentImageView.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var messageBubbleView: UIView! {
        
        didSet {
            
            messageBubbleView.backgroundColor = .projectBackgroundColor2
        }
    }
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightTimeLabel: UILabel! {
        
        didSet {
            
            rightTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            
            rightTimeLabel.textColor = .projectPlaceHolderColor
        }
    }
    
    func configureCell(with viewModel: MessageViewModel, friend: User) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        if currentUser.id == viewModel.message.senderId {
            
            rightTimeLabel.textAlignment = .right
            
            contentLabel.textAlignment = .right
            
            friendImageView.isHidden = true
            
        } else {
            
            rightTimeLabel.textAlignment = .left
            
            contentLabel.textAlignment = .left
           
            friendImageView.isHidden = false
        }
        
        friendImageView.loadImage(friend.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userImageView.isHidden = friendImageView.isHidden
        ? false
        : true
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        rightTimeLabel.text = viewModel.message.createdTime.formatedTime
        
        messageBubbleView.isHidden = true
        
        contentImageView.isHidden = true
        
        if
            let content = viewModel.message.content,
            content != "" {
            
            contentLabel.text = content
            
            messageBubbleView.isHidden = false
            
            imageViewHeightConstraint.constant = 0
            
        } else if
            let imageURLString = viewModel.message.contentImageURLString {
            
            contentImageView.loadImage(imageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
            
            contentImageView.isHidden = false
            
            imageViewHeightConstraint.constant = 150
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.height / 2

        friendImageView.layer.cornerRadius = userImageView.frame.height / 2
        
        messageBubbleView.layer.cornerRadius = 12
        
        contentImageView.layer.cornerRadius = 12
    }
}
