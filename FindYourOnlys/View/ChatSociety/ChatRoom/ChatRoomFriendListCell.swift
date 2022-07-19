//
//  ChatRoomFriendListCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/15.
//

import UIKit

class ChatRoomFriendListCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet private weak var friendImageView: UIImageView!
    
    @IBOutlet private weak var friendNickNameLabel: UILabel!
    
    @IBOutlet private weak var lastTextLabel: UILabel!
    
    @IBOutlet private weak var lastTextSentTimeLabel: UILabel!
    
    // MARK: - Methods
    
    func configureCell(with friend: User) {
        
        friendImageView.loadImage(friend.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        friendNickNameLabel.text = friend.nickName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendImageView.makeRound()
    }
    
}
