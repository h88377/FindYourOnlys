//
//  ArticlePhotoCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticlePhotoCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.backgroundColor = .projectBackgroundColor
            
            userImageView.contentMode = .scaleAspectFill
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var userNameLabel: UILabel! {
        
        didSet {
            
            userNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            userNameLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var postedImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var postTypeView: UIView!
    
    @IBOutlet weak var postTypeLabel: UILabel! {
        
        didSet {
            
            postTypeLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    @IBOutlet weak var locationImage: UIImageView! {
        
        didSet {
            
            locationImage.tintColor = .projectIconColor2
        }
    }
    
    @IBOutlet weak var cityLabel: UILabel! {
        
        didSet {
            
            cityLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        
        didSet {
            
            editButton.setImage(UIImage.asset(.edit)?.withTintColor(.projectIconColor1), for: .normal)
            
            editButton.setImage(UIImage.asset(.edit)?.withTintColor(.projectIconColor2), for: .highlighted)
        }
    }
    
    var editHandler: (() -> Void)?
    
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
    
    func configureCell(with viewModel: ArticleViewModel, authorViewModel: UserViewModel) {

        userImageView.loadImage(authorViewModel.user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userNameLabel.text = authorViewModel.user.nickName
        
        postedImageView.loadImage(viewModel.article.imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        timeLabel.text =  viewModel
            .article
            .createdTime
            .formatedTime
        
        cityLabel.text = viewModel.article.city
        
        switch viewModel.article.postType {
            
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
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userNameLabel.text = currentUser.nickName
        
        postedImageView.loadImage(viewModel.article.imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        timeLabel.text = viewModel.article.createdTime.formatedTime
        
        cityLabel.text = viewModel.article.city
        
        switch viewModel.article.postType {
            
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

extension ArticlePhotoCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return postedImageView
    }
}
