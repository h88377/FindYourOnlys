//
//  ChatRoomCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit

class ChatRoomMessageCell: UITableViewCell {
    
    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var messageBubbleView: UIView!
    
    func configureCell(with viewModel: ThreadViewModel, friendImageURLString: String) {
        
        friendImageView.isHidden = UserFirebaseManager.shared.currentUser == viewModel.thread.senderId
        ? true
        : false
        
        friendImageView.loadImage(friendImageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
        
        if
            let content = viewModel.thread.content {
            
            contentLabel.text = content
            
        } else if
            
            let imageURLString = viewModel.thread.contentImageURLString {
            
            contentImageView.loadImage(imageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
        }
        
    }
}
