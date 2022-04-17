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
    
    @IBOutlet weak var postTypeLabel: UILabel! {
        
        didSet {
            
            postTypeLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    @IBOutlet weak var locationImage: UIImageView! {
        
        didSet {
            
            locationImage.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
 
    @IBOutlet weak var colorLabel: UILabel!
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        likeCountLabel.text = "\(viewModel.article.likeUserIds.count)"
        
        commentCountLabel.text = "\(viewModel.article.comments.count)"
        
//        cityLabel.text = viewModel.article.city
        
        kindLabel.text = viewModel.article.petKind
        
        contentLabel.text = viewModel.article.content
        
        colorLabel.text = viewModel.article.color
        
//        switch viewModel.article.postType {
//            
//        case 0:
//            
//            postTypeLabel.text = PostType.allCases[0].rawValue
//            
//        case 1:
//            
//            postTypeLabel.text = PostType.allCases[1].rawValue
//            
//        default:
//            
//            postTypeLabel.text = "error type."
//        }   
    }
}
