//
//  ArticleContentCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticleContentCell: UITableViewCell {

    @IBOutlet weak var likeButton: TransformButton! {
        
        didSet {
            
            likeButton.setImage(UIImage.system(.addToFavorite), for: .normal)
            
            likeButton.setImage(UIImage.system(.removeFromFavorite), for: .selected)
            
            likeButton.tintColor = .projectIconColor1
            
            likeButton.adjustsImageWhenHighlighted = false
        }
    }
    
    @IBOutlet weak var leaveCommentButton: UIButton! {
        
        didSet {
            
            leaveCommentButton.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        
        didSet {
            
            shareButton.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var likeCountLabel: UILabel! {
        
        didSet {
            
            likeCountLabel.textColor = .projectIconColor2
        }
    }
    
    @IBOutlet weak var commentCountLabel: UILabel! {
        
        didSet {
            
            commentCountLabel.textColor = .projectIconColor2
        }
    }
    
    @IBOutlet weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            
            kindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel! {
        
        didSet {
            
            contentLabel.textColor = .projectTextColor
        }
    }
 
    @IBOutlet weak var colorLabel: UILabel! {
        
        didSet {
            
            colorLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var separatorView: UIView! {
        
        didSet {
            
            separatorView.backgroundColor = .systemGray5
        }
    }
    
    var leaveCommentHandler: (() -> Void)?
    
    var likeArticleHandler: (() -> Void)?
    
    var unlikeArticleHandler: (() -> Void)?
    
    var shareHandler: (() -> Void)?
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        likeCountLabel.text = "\(viewModel.article.likeUserIds.count)"
        
        commentCountLabel.text = "\(viewModel.article.comments.count)"
        
        kindLabel.text = viewModel.article.petKind
        
        contentLabel.text = viewModel.article.content
        
        colorLabel.text = viewModel.article.color
        
        hideLike(viewModel: viewModel)
        
        if
            let currentUser = UserFirebaseManager.shared.currentUser {
            
            likeButton.isSelected = viewModel.article.likeUserIds.contains(currentUser.id)
            
        } else {
            
            likeButton.isSelected = false
        }
    }
    
    func hideLike(viewModel: ArticleViewModel) {
        
        if viewModel.article.postType != nil {
            
            likeButton.isHidden = true
            
            likeCountLabel.isHidden = true
        }
    }
    
    @IBAction func leaveComment(_ sender: UIButton) {
        
        leaveCommentHandler?()
    }
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        
        switch likeButton.isSelected {
            
        case true:
            
            unlikeArticleHandler?()
            
        case false:
            
            likeArticleHandler?()
            
        }
        
    }
    
    @IBAction func share(_ sender: UIButton) {
           
        shareHandler?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        shareHandler = nil
        
        unlikeArticleHandler = nil
        
        likeArticleHandler = nil
        
        leaveCommentHandler = nil
    }
    
}
