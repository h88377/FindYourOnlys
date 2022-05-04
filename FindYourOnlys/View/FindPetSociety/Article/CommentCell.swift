//
//  CommentCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/27.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var nickNameLabel: UILabel! {
        
        didSet {
            
            nickNameLabel.textColor = .projectTextColor
            
            nickNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var commentLabel: UILabel! {
        
        didSet {
            
            commentLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var createdTimeLabel: UILabel! {
        
        didSet {
            
            createdTimeLabel.textColor = .projectPlaceHolderColor
            
            createdTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        
        didSet {
            
            let image = UIImage.asset(.edit)?.withTintColor(.projectIconColor1, renderingMode: .alwaysOriginal)
            
            editButton.imageView?.image = image
        }
    }
    
    @IBOutlet weak var userImageView: UIImageView!
    
    var editHandler: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }
    
    func configure(with viewModel: CommentViewModel, senderViewModel: UserViewModel) {
        
        nickNameLabel.text = senderViewModel.user.nickName
        
        commentLabel.text = viewModel.comment.content
        
        createdTimeLabel.text = viewModel.comment.createdTime.formatedTime
        
        userImageView.loadImage(senderViewModel.user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
    }
    
    @IBAction func edit(_ sender: UIButton) {
        
        editHandler?()
    }
}
