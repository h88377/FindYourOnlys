//
//  ArticlePhotoCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticlePhotoCell: UITableViewCell {

    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel! {
        
        didSet {
            
            userNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    @IBOutlet weak var postedImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
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
    
    var editHandler: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard
            let imageView = userButton.imageView else { return }
        
        userButton.imageView?.layer.cornerRadius = imageView.layer.frame.height / 2
        
        postedImageView.layer.cornerRadius = 15
    }
    
    func configureCell(with viewModel: ArticleViewModel, authorViewModel: UserViewModel) {
        
        let userImageView = UIImageView()
        
        userImageView.loadImage(authorViewModel.user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userButton.setImage(userImageView.image, for: .normal)
        
        userNameLabel.text = authorViewModel.user.nickName
        
        postedImageView.loadImage(viewModel.article.imageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
        
        timeLabel.text =  viewModel.article.createdTime.formatedTime
        
        cityLabel.text = viewModel.article.city
        
        switch viewModel.article.postType {
            
        case 0:
            
            postTypeLabel.text = PostType.allCases[0].rawValue
            
        case 1:
            
            postTypeLabel.text = PostType.allCases[1].rawValue
            
        default:
            
            postTypeLabel.text = ""
        }   
    }
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        let userImageView = UIImageView()
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userButton.setImage(userImageView.image, for: .normal)
        
        userNameLabel.text = currentUser.nickName
        
        postedImageView.loadImage(viewModel.article.imageURLString, placeHolder: UIImage.system(.messagePlaceHolder))
        
        timeLabel.text =  viewModel.article.createdTime.formatedTime
        
        cityLabel.text = viewModel.article.city
        
        switch viewModel.article.postType {
            
        case 0:
            
            postTypeLabel.text = PostType.allCases[0].rawValue
            
        case 1:
            
            postTypeLabel.text = PostType.allCases[1].rawValue
            
        default:
            
            postTypeLabel.text = ""
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
