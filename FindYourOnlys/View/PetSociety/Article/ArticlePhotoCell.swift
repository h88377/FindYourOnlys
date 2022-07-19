//
//  ArticlePhotoCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticlePhotoCell: UITableViewCell {

    // MARK: - Properties
    
    @IBOutlet private weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.backgroundColor = .projectBackgroundColor
            
            userImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    @IBOutlet private weak var userNameLabel: UILabel! {
        
        didSet {
            
            userNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            userNameLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var postedImageView: UIImageView!
    
    @IBOutlet private weak var timeLabel: UILabel!
    
    @IBOutlet private weak var postTypeView: UIView!
    
    @IBOutlet private weak var postTypeLabel: UILabel! {
        
        didSet {
            
            postTypeLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    @IBOutlet private weak var locationImage: UIImageView! {
        
        didSet {
            
            locationImage.tintColor = .projectIconColor2
        }
    }
    
    @IBOutlet private weak var cityLabel: UILabel! {
        
        didSet {
            
            cityLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var editButton: UIButton! {
        
        didSet {
            
            editButton.setImage(UIImage.asset(.edit)?.withTintColor(.projectIconColor1), for: .normal)
            
            editButton.setImage(UIImage.asset(.edit)?.withTintColor(.projectIconColor2), for: .highlighted)
        }
    }
    
    var editHandler: (() -> Void)?
    
    // MARK: - Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        scrollView.minimumZoomScale = 1
        
        scrollView.maximumZoomScale = 3.5
        
        scrollView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.makeRound()
        
        postedImageView.layer.cornerRadius = 15
        
        postTypeView.layer.cornerRadius = 15
        
        postTypeView.clipsToBounds = true
    }
    
    func configureCell(with article: Article, author: User) {

        userImageView.loadImage(
            author.imageURLString,
            placeHolder: UIImage.system(.personPlaceHolder))
        
        userNameLabel.text = author.nickName
        
        postedImageView.loadImage(
            article.imageURLString,
            placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        timeLabel.text = article.createdTime.formatedTime
        
        cityLabel.text = article.city
        
        switch article.postType {
            
        case 0:
            
            postTypeLabel.text = PostType.allCases[0].rawValue
            
            postTypeLabel.textColor = .projectTextColor
            
            postTypeView.backgroundColor = .projectIconColor3
            
        case 1:
            
            postTypeLabel.text = PostType.allCases[1].rawValue
            
            postTypeLabel.textColor = .white
            
            postTypeView.backgroundColor = .projectIconColor1
            
        default:
            
            postTypeLabel.isHidden = true
            
            postTypeView.isHidden = true
        }   
    }
    
    func configureCell(with article: Article) {
        
        guard let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        userImageView.loadImage(
            currentUser.imageURLString,
            placeHolder: UIImage.system(.personPlaceHolder))
        
        userNameLabel.text = currentUser.nickName
        
        postedImageView.loadImage(
            article.imageURLString,
            placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        timeLabel.text = article.createdTime.formatedTime
        
        cityLabel.text = article.city
        
        switch article.postType {
            
        case 0:
            
            postTypeLabel.text = PostType.allCases[0].rawValue
            
            postTypeLabel.textColor = .projectTextColor
            
            postTypeView.backgroundColor = .projectIconColor3
            
        case 1:
            
            postTypeLabel.text = PostType.allCases[1].rawValue
            
            postTypeLabel.textColor = .white
            
            postTypeView.backgroundColor = .projectIconColor1
            
        default:
            
            postTypeLabel.isHidden = true
            
            postTypeView.isHidden = true
        }
    }
    
    @IBAction func edit(_ sender: UIButton) {
        
        editHandler?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        editHandler = nil
    }
}

// MARK: - UIScrollViewDelegate

extension ArticlePhotoCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return postedImageView
    }
}
