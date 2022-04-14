//
//  ArticlePhotoCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

class ArticlePhotoCell: UITableViewCell {

    @IBOutlet weak var userButton: UIButton!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var postedImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    func configureCell(with viewModel: ArticleViewModel) {
        
        userButton.setImage(UIImage.system(.personPlaceHolder), for: .normal)
        
        userNameLabel.text = viewModel.article.userId
        
        postedImageView.loadImage(viewModel.article.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        timeLabel.text = formateTime(with: viewModel.article.createdTime)
    }
    
    func formateTime(with time: TimeInterval) -> String {
        
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        
        let date = NSDate(timeIntervalSince1970: time)

        let dateString = formatter.string(from: date as Date)
        
        return dateString
    }
    
}
