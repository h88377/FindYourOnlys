//
//  AdoptDetailTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

class AdoptDetailTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet private weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            
            statusLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.textColor = .projectTextColor
            
            kindLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    @IBOutlet private weak var sexLabel: UILabel! {
        
        didSet {
            
            sexLabel.textColor = .projectIconColor3
            
            sexLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        }
    }
    
    @IBOutlet private weak var varietyLabel: UILabel! {
        
        didSet {
            
            varietyLabel.textColor = .projectTextColor
            
            varietyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
    }
    
    @IBOutlet private var baseViews: [UIView]! {
        
        didSet {
            
            baseViews.forEach { $0.backgroundColor = .projectBackgroundColor }
        }
    }
    
    @IBOutlet private weak var shareButton: UIButton! {
        
        didSet {
            
            shareButton.setTitleColor(.projectTextColor, for: .normal)
            
            shareButton.setTitleColor(.white, for: .highlighted)
            
            shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            
            shareButton.backgroundColor = .projectIconColor3
        }
    }
    
    var shareHandler: (() -> Void)?
    
    // MARK: - Methods and IBActions
    override func prepareForReuse() {
        super.prepareForReuse()
        
        shareHandler = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseViews.forEach { $0.layer.cornerRadius = 15 }
        
        shareButton.layer.cornerRadius = 10
    }
    
    func configureCell(with pet: Pet) {
        
        kindLabel.text = pet.kind
        
        varietyLabel.text = pet.variety
        
        if pet.status == "OPEN" {
            
            statusLabel.text = "開放認養"
            
        } else {
            
            statusLabel.text = "不開放認養"
        }
        
        if pet.sex == "M" {
            
            sexLabel.text = "♂"
            
            sexLabel.textColor = .maleColor
            
        } else {
            
            sexLabel.text = "♀"
            
            sexLabel.textColor = .femaleColor
        }
    }
    
    @IBAction func share(_ sender: UIButton) {
        
        shareHandler?()
    }
}
