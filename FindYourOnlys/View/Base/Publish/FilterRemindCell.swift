//
//  FilterRemindCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/5.
//

import UIKit
import Lottie

enum RemindType {
    
    case allowOneCondition
    
    case allCondition
}

class FilterRemindCell: UITableViewCell {
    
    @IBOutlet private weak var animationView: AnimationView! {
        
        didSet {
            
            animationView.loopMode = .loop
            
            animationView.play()
        }
    }
    
    @IBOutlet private weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
            
            remindLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        }
    }
    
    func configureCell(with remindType: RemindType) {
        
        switch remindType {
        case .allowOneCondition:
            
            remindLabel.text = "選擇一項條件即可搜尋囉！"
            
        case .allCondition:
            
            remindLabel.text = "選擇全部條件才可以搜尋喔！"
        }
        
    }
}
