//
//  ArticleContentCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticleContentCell: UITableViewCell {

    @IBOutlet weak var likeButton: UIButton! {
        
        didSet {
            
            likeButton.setImage(UIImage.system(.addToFavorite), for: .normal)
            
            likeButton.setImage(UIImage.system(.removeFromFavorite), for: .selected)
        }
    }
    
    @IBOutlet weak var leaveCommentButton: UIButton!
    
    @IBOutlet weak var shareButton: UIButton!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    @IBOutlet weak var contentLabel: UILabel!
 
    @IBOutlet weak var colorLabel: UILabel!
    
    var leaveCommentHandler: (() -> Void)?
    
    var likeArticleHandler: (() -> Void)?
    
    var unlikeArticleHandler: (() -> Void)?
    
    var shareHandler: (() -> Void)?
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        likeCountLabel.text = "\(viewModel.article.likeUserIds.count)"
        
        commentCountLabel.text = "\(viewModel.article.comments.count)"
        
        kindLabel.text = viewModel.article.petKind
        
        contentLabel.text = viewModel.article.content
        
        colorLabel.text = viewModel.article.color
        
        likeButton.isSelected = viewModel.article.likeUserIds.contains(currentUser.id)
         
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
