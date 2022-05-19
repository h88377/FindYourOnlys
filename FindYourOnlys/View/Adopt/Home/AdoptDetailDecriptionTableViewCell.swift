//
//  NewAdoptDetailDecriptionTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

class AdoptDetailDecriptionTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        
        didSet {
            
            descriptionLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var itemLabel: UILabel! {
        
        didSet {
            
            itemLabel.textColor = .projectTextColor
        }
    }
    
    // MARK: - Methods
    
    func configureCell(description: String, content: String) {
        
        descriptionLabel.text = description
        
        switch content {
            
        case "":
            itemLabel.text = "無"
            
        case "F":
            
            itemLabel.text = "否"
            
        case "T":
            
            itemLabel.text = "是"
            
        case "SMALL":
            
            itemLabel.text = "小型"
            
        case "MEDIUM":
            
            itemLabel.text = "中型"
            
        case "BIG":
            
            itemLabel.text = "大型"
            
        case "ADULT":
            
            itemLabel.text = "成年"
            
        case "CHILD":
            
            itemLabel.text = "幼年"
            
        default:
            
            itemLabel.text = content
            
        }
    }
}
