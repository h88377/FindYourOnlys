//
//  ProfileArticleHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import UIKit

class ProfileArticleHeaderView: UICollectionReusableView {

    @IBOutlet private weak var headerLabel: UILabel! {
        
        didSet {
            
            headerLabel.textColor = .projectTextColor
        }
    }
    
    func configureView(with profileArticle: ProfileArticle) {
        
        headerLabel.text = profileArticle.articleType.rawValue
    }
}
