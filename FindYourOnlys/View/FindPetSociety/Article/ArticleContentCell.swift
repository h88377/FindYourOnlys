//
//  ArticleContentCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticleContentCell: UITableViewCell {

    @IBOutlet weak var likeButton: UIButton!
    
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
    
    var leaveMessageHandler: (() -> Void)?
    
    var toggleFavoriteHandler: (() -> Void)?
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        likeCountLabel.text = "\(viewModel.article.likeUserIds.count)"
        
        commentCountLabel.text = "\(viewModel.article.comments.count)"
        
        kindLabel.text = viewModel.article.petKind
        
        contentLabel.text = viewModel.article.content
        
        colorLabel.text = viewModel.article.color
         
    }
    
    @IBAction func leaveMessage(_ sender: UIButton) {
        
        leaveMessageHandler?()
    }
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        
        toggleFavoriteHandler?()
    }
    
}
