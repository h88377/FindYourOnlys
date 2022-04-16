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
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var messageBubbleView: UIView!
    
    func configureCell(with viewModel: MessageViewModel, friend: User) {
        
        friendImageView.isHidden = UserFirebaseManager.shared.currentUser == viewModel.message.senderId
        ? true
        : false
        
        friendImageView.loadImage(friend.imageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
        
        userImageView.isHidden = friendImageView.isHidden
        ? false
        : true
        userImageView.loadImage(UserFirebaseManager.shared.currentUserImageURL, placeHolder: UIImage.system(.personPlaceHolder))
        
        
        messageBubbleView.isHidden = true
        
        contentImageView.isHidden = true
        if
            let content = viewModel.message.content,
            content != "" {
            
            contentLabel.text = content
            
            messageBubbleView.isHidden = false
            
        } else if
            let imageURLString = viewModel.message.contentImageURLString {
            
            contentImageView.loadImage(imageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
            
            contentLabel.isHidden = false
        }
        
    }
}
