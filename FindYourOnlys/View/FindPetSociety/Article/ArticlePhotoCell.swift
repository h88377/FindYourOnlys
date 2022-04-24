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
        
        timeLabel.text = formateTime(with: viewModel.article.createdTime)
        
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
    
    func formateTime(with time: TimeInterval) -> String {
        
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        
        let date = NSDate(timeIntervalSince1970: time)

        let dateString = formatter.string(from: date as Date)
        
        return dateString
    }
    
    
}
