//
//  ChatRoomFriendListCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import UIKit

class ChatRoomFriendListCell: UITableViewCell {

    @IBOutlet weak var friendImageView: UIImageView!
    
    @IBOutlet weak var friendNickNameLabel: UILabel!
    
    @IBOutlet weak var lastTextLabel: UILabel!
    
    @IBOutlet weak var lastTextSentTimeLabel: UILabel!
    
    func configureCell(with viewModel: UserViewModel) {
        
        friendImageView.loadImage(viewModel.user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendImageView.layer.cornerRadius = friendImageView.frame.height / 2
    }
    
}
