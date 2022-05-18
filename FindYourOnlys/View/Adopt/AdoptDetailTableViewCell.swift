//
//  AdoptDetailTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

class AdoptDetailTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            
            statusLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.textColor = .projectTextColor
            
            kindLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    @IBOutlet weak var sexLabel: UILabel! {
        
        didSet {
            
            sexLabel.textColor = .projectIconColor3
            
            sexLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        }
    }
    
    @IBOutlet weak var varietyLabel: UILabel! {
        
        didSet {
            
            varietyLabel.textColor = .projectTextColor
            
            varietyLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
    }
    
    @IBOutlet var baseViews: [UIView]! {
        
        didSet {
            
            baseViews.forEach { $0.backgroundColor = .projectBackgroundColor }
        }
    }
    
    @IBOutlet weak var shareButton: UIButton! {
        
        didSet {
            
            shareButton.setTitleColor(.projectTextColor, for: .normal)
            
            shareButton.setTitleColor(.white, for: .highlighted)
            
            shareButton.titleLabel?.font = UIFont.systemFont(ofSize: Constant.textSize, weight: .regular)
            
            shareButton.backgroundColor = .projectIconColor3
        }
    }
    
    var shareHandler: (() -> Void)?
    
    // MARK: - Life Cycle
    override func prepareForReuse() {
        super.prepareForReuse()
        
        shareHandler = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseViews.forEach { $0.layer.cornerRadius = 15 }
        
        shareButton.layer.cornerRadius = 10
    }
    
    // MARK: - Methods and IBActions
    func configureCell(with viewModel: PetViewModel) {
        
        kindLabel.text = viewModel.pet.kind
        
        varietyLabel.text = viewModel.pet.variety
        
        if viewModel.pet.status == "OPEN" {
            
            statusLabel.text = "開放認養"
            
        } else {
            
            statusLabel.text = "不開放認養"
        }
        
        if viewModel.pet.sex == "M" {
            
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
