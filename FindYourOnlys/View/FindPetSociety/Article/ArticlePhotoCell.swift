//
//  ArticlePhotoCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticlePhotoCell: UITableViewCell {

    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var userNameLabel: UILabel! {
        
        didSet {
            
            userNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            userNameLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var postedImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var postTypeLabel: UILabel! {
        
        didSet {
            
            postTypeLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
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
            
            editButton.tintColor = .projectIconColor1
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
        
        guard
            let imageView = userButton.imageView else { return }
        
        userButton.imageView?.layer.cornerRadius = imageView.layer.frame.height / 2
        
        postedImageView.layer.cornerRadius = 15
        
        postTypeLabel.layer.cornerRadius = 12
        
        postTypeLabel.clipsToBounds = true
    }
    
    func configureCell(with viewModel: ArticleViewModel, authorViewModel: UserViewModel) {
        
        let userImageView = UIImageView()
        
        userImageView.loadImage(authorViewModel.user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userButton.setImage(userImageView.image, for: .normal)
        
        userNameLabel.text = authorViewModel.user.nickName
        
        postedImageView.loadImage(viewModel.article.imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        timeLabel.text =  viewModel.article.createdTime.formatedTime
        
        cityLabel.text = viewModel.article.city
        
        switch viewModel.article.postType {
            
        case 0:
            
            postTypeLabel.text = PostType.allCases[0].rawValue
            
            postTypeLabel.textColor = .projectTextColor
            
            postTypeLabel.backgroundColor = .projectIconColor3
            
        case 1:
            
            postTypeLabel.text = PostType.allCases[1].rawValue
            
            postTypeLabel.textColor = .white
            
            postTypeLabel.backgroundColor = .projectIconColor1
            
        default:
            
            postTypeLabel.text = ""
            
            postTypeLabel.backgroundColor = .white
        }   
    }
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        let userImageView = UIImageView()
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userButton.setImage(userImageView.image, for: .normal)
        
        userNameLabel.text = currentUser.nickName
        
        postedImageView.loadImage(viewModel.article.imageURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        timeLabel.text =  viewModel.article.createdTime.formatedTime
        
        cityLabel.text = viewModel.article.city
        
        switch viewModel.article.postType {
            
        case 0:
            
            postTypeLabel.text = PostType.allCases[0].rawValue
            
            postTypeLabel.textColor = .white
            
            postTypeLabel.backgroundColor = .projectTextColor
            
        case 1:
            
            postTypeLabel.text = PostType.allCases[1].rawValue
            
            postTypeLabel.textColor = .white
            
            postTypeLabel.backgroundColor = .projectIconColor1
            
        default:
            
            postTypeLabel.text = ""
            
            postTypeLabel.backgroundColor = .white
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
