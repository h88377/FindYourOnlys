//
//  FriendRequestCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit

class FriendRequestCell: UITableViewCell {

    @IBOutlet weak var userImageVIew: UIImageView!
    
    @IBOutlet weak var nickNameLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var waitAcceptButton: UILabel!
    
    func configureCell(with type: FriendRequestType, user: User) {
        
        nickNameLabel.text = user.nickName
        
        idLabel.text = user.id
        
        userImageVIew.loadImage(user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        switch type {
            
        case .requested:
            
            acceptButton.isHidden = false
            
            rejectButton.isHidden = false
            
            waitAcceptButton.isHidden = true
            
        case .request:
            
            acceptButton.isHidden = true
            
            rejectButton.isHidden = true
            
            waitAcceptButton.isHidden = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageVIew.layer.cornerRadius = userImageVIew.frame.height / 2
    }
    
    @IBAction func accept(_ sender: UIButton) {
    }
    
    @IBAction func reject(_ sender: UIButton) {
    }
}
