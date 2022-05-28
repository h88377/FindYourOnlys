//
//  CommentCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import UIKit

class CommentCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet private weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.textColor = .projectTextColor
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet private weak var commentLabel: UILabel! {
        
        didSet {
            
            commentLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var createdTimeLabel: UILabel! {
        
        didSet {
            
            createdTimeLabel.textColor = .projectPlaceHolderColor
            
            createdTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    @IBOutlet private weak var editButton: UIButton! {
        
        didSet {
            
            editButton.setTitleColor(.projectIconColor1, for: .normal)
            editButton.setTitleColor(.projectIconColor2, for: .highlighted)
        }
    }
    
    @IBOutlet private weak var userImageView: UIImageView!
    
    @IBOutlet private weak var separatorView: UIView! {
        
        didSet {
            
            separatorView.backgroundColor = .systemGray5
        }
    }
    
    var blockHandler: (() -> Void)?
    
    // MARK: - Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.makeRound()
    }
    
    func configure(with viewModel: CommentViewModel, senderViewModel: UserViewModel) {
        
        nickNameLabel.text = senderViewModel.user.nickName
        
        commentLabel.text = viewModel.comment.content
        
        createdTimeLabel.text = viewModel.comment.createdTime.formatedTime
        
        userImageView.loadImage(senderViewModel.user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        if
            let currentUser = UserFirebaseManager.shared.currentUser
            
        {
            editButton.isHidden = currentUser.id == senderViewModel.user.id
        }
    }
    
    @IBAction func block(_ sender: UIButton) {
        
        blockHandler?()
    }
}
