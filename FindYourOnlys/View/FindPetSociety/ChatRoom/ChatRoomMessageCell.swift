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
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var contentImageView: UIImageView! {
        
        didSet {
            
            contentImageView.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var messageBubbleView: UIView!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    func configureCell(with viewModel: MessageViewModel, friend: User) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        friendImageView.isHidden = currentUser.id == viewModel.message.senderId
        ? true
        : false
        
        friendImageView.loadImage(friend.imageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
        
        userImageView.isHidden = friendImageView.isHidden
        ? false
        : true
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        
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
