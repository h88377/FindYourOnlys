//
//  NewAdoptDetailDecriptionTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

class AdoptDetailDecriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        
        didSet {
            
            descriptionLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var itemLabel: UILabel! {
        
        didSet {
            
            itemLabel.textColor = .projectTextColor
        }
    }
    
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
//
//
//        if content == "" {
//
//            itemLabel.text = "無"
//
//        } else if content == "F" {
//
//            itemLabel.text = "否"
//
//        } else if content == "T" {
//
//            itemLabel.text = "是"
//
//        } else if content == "SMALL" {
//
//            itemLabel.text = "小型"
//
//        } else if content == "MEDIUM" {
//
//            itemLabel.text = "中型"
//
//        } else if content == "BIG" {
//
//            itemLabel.text = "大型"
//
//        } else {
//
//            itemLabel.text = content
//        }
    }
}
