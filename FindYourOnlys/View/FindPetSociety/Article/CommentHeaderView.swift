//
//  CommentHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import UIKit

class CommentHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var userNickNameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    func configureView(with article: Article, author: User) {
        
        let userImageView = UIImageView()
        
        userImageView.loadImage(author.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userButton.setImage(userImageView.image, for: .normal)
        
        userNickNameLabel.text = author.nickName
        
        timeLabel.text = article.createdTime.formatedTime
        
        contentLabel.text = article.content
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard
            let imageView = userButton.imageView else { return }
        
        userButton.imageView?.layer.cornerRadius = imageView.layer.frame.height / 2
    }
}
