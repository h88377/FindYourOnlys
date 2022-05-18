//
//  PublishUserCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishUserCell: PublishBasicCell {
    
    @IBOutlet weak var userImageView: UIImageView! {
        
        didSet {
            
            userImageView.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var userNickName: UILabel! {
        
        didSet {
            
            userNickName.textColor = .projectTextColor
            
            userNickName.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    //no need
    @IBOutlet weak var timeLabel: UILabel!
    
    override func layoutCell(article: Article? = nil) {
        
        guard
            let currentUser = UserFirebaseManager.shared.currentUser else { return }
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userNickName.text = currentUser.nickName

        
//        timeLabel.text = formateTime(with: viewModel.article.createdTime)
        
        
    }
    
    private func formateTime(with time: TimeInterval) -> String {
        
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        
        let date = NSDate(timeIntervalSince1970: time)

        let dateString = formatter.string(from: date as Date)
        
        return dateString
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.makeRound()
    }
}
