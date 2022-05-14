//
//  ProfileArticleCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import UIKit

class ProfileArticleCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        
        didSet {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                
                self.transform = self.isSelected
                ? CGAffineTransform(scaleX: 0.7, y: 0.7)
                : CGAffineTransform.identity
            }
        }
    }
    
    override var isHighlighted: Bool {
        
        didSet {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                
                self.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.9, y: 0.9)
                : CGAffineTransform.identity
            }
        }
    }
    
    @IBOutlet weak var articleImageView: UIImageView!
    
    func configureCell(with article: Article) {
        
        articleImageView.loadImage(article.imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        articleImageView.layer.cornerRadius = 15
    }
}
