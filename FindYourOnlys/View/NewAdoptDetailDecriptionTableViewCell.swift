//
//  NewAdoptDetailDecriptionTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

class NewAdoptDetailDecriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var itemLabel: UILabel!
    
    func configureCell(description: String, content: String) {
        
        descriptionLabel.text = description
        
        itemLabel.text = content
    }
    
}
