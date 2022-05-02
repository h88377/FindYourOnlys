//
//  ProfileArticleHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import UIKit

class ProfileArticleHeaderView: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel! {
        
        didSet {
            
            headerLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var checkAllButton: UIButton!
    
    @IBAction func checkAllArticles(_ sender: UIButton) {
    }
    
    func configureView(with profileArticle: ProfileArticle) {
        
        headerLabel.text = profileArticle.articleType.rawValue
    }
}
