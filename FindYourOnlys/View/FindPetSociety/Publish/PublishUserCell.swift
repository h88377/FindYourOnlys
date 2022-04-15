//
//  PublishUserCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishUserCell: PublishBasicCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNickName: UILabel!
    
    //no need
    @IBOutlet weak var timeLabel: UILabel!
    
    override func layoutCell() {
        
        userImageView.loadImage("wait fetch userPhoto", placeHolder: UIImage.system(.personPlaceHolder))
        
        userNickName.text = UserFirebaseManager.shared.currentUser

        
//        timeLabel.text = formateTime(with: viewModel.article.createdTime)
        
        
    }
    
    private func formateTime(with time: TimeInterval) -> String {
        
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy.MM.dd hh:mm"
        
        let date = NSDate(timeIntervalSince1970: time)

        let dateString = formatter.string(from: date as Date)
        
        return dateString
    }
}
