//
//  ProfileArticleCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import UIKit

class ProfileArticleCell: UICollectionViewCell {
    
    @IBOutlet weak var articleImageView: UIImageView!
    
    func configureCell(with article: Article) {
        
        articleImageView.loadImage(article.imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        articleImageView.layer.cornerRadius = 15
    }
}
