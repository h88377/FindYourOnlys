//
//  AdoptDetailTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

class AdoptDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var varietyLabel: UILabel!
    
    @IBOutlet var baseViews: [UIView]!
    
    func configureCell(with viewModel: PetViewModel) {
        
        kindLabel.text = viewModel.pet.kind
        
        varietyLabel.text = viewModel.pet.variety
        
        if viewModel.pet.status == "OPEN" {
            
            statusLabel.text = "開放認養"
            
//            statusLabel.textColor = .openAdopt
            
        } else {
            
            statusLabel.text = "不開放認養"
            
//            statusLabel.textColor = .closeAdopt
        }
        
        if viewModel.pet.sex == "M" {
            
            sexLabel.text = Sex.male.rawValue
            
//            sexLabel.textColor = .maleColor
            
        } else {
            
            sexLabel.text = Sex.female.rawValue
            
//            sexLabel.textColor = .femaleColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseViews.forEach { $0.layer.cornerRadius = 15 }
    }
}
