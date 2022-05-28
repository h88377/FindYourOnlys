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
    
    func configureCell(with viewModel: UserViewModel) {
        
        friendImageView.loadImage(viewModel.user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        friendNickNameLabel.text = viewModel.user.nickName
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        friendImageView.makeRound()
    }
    
}
