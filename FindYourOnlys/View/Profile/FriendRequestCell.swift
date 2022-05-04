//
//  FriendRequestCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit

class FriendRequestCell: UITableViewCell {

    @IBOutlet weak var userImageVIew: UIImageView!
    
    @IBOutlet weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            nickNameLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var emailLabel: UILabel! {
        
        didSet {
            
            emailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            
            emailLabel.textColor = .projectPlaceHolderColor
        }
    }
    
    @IBOutlet weak var acceptButton: UIButton! {
        
        didSet {
            
            acceptButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            acceptButton.backgroundColor = .projectIconColor1
            
            acceptButton.setTitleColor(.white, for: .normal)
            
            acceptButton.setTitleColor(.projectIconColor2, for: .highlighted)
        }
    }
    
    @IBOutlet weak var rejectButton: UIButton! {
        
        didSet {
            
            rejectButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            rejectButton.backgroundColor = .projectIconColor1
            
            rejectButton.setTitleColor(.white, for: .normal)
            
            rejectButton.setTitleColor(.projectIconColor2, for: .highlighted)
        }
    }
    
    @IBOutlet weak var waitAcceptButton: UILabel! {
        
        didSet {
            
            waitAcceptButton.textColor = .projectTextColor
        }
    }
    
    var acceptHandler: (() -> Void)?
    
    var rejectHandler: (() -> Void)?
    
    func configureCell(with type: FriendRequestType, user: User) {
        
        nickNameLabel.text = user.nickName
        
        emailLabel.text = user.email
        
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
        
        acceptButton.layer.cornerRadius = 12
        
        rejectButton.layer.cornerRadius = 12
    }
    
    @IBAction func accept(_ sender: UIButton) {
        
        acceptHandler?()
    }
    
    @IBAction func reject(_ sender: UIButton) {
        
        rejectHandler?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        acceptHandler = nil
        
        rejectHandler = nil
    }
}
