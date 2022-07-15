//
//  FavoriteCollectionViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet private weak var photoImageView: UIImageView!
    
    @IBOutlet private weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            
            kindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var sexLabel: UILabel! {
        
        didSet {
            
            sexLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
            
            sexLabel.textColor = .projectIconColor3
        }
    }
    
    @IBOutlet private weak var varietyLabel: UILabel! {
        
        didSet {
            
            varietyLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .white
        }
    }
    
    @IBOutlet private weak var locationImageView: UIImageView! {
        
        didSet {
            
            locationImageView.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var bacterinLabel: UILabel! {
        
        didSet {
            
            bacterinLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var sterilizationLabel: UILabel! {
        
        didSet {
            
            sterilizationLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var organizationLabel: UILabel! {
        
        didSet {
            
            organizationLabel.textColor = .projectTextColor
        }
    }
    
    // MARK: - Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedView = UIView()
        
        let backgroundView = UIView()
        
        selectedView.backgroundColor = UIColor.systemGray5
        
        backgroundView.backgroundColor = UIColor.systemGray6
        
        self.selectedBackgroundView = selectedView
        
        self.backgroundView = backgroundView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        photoImageView.layer.cornerRadius = 15
        
        baseView.layer.cornerRadius = 15
    }
    
    func configureCell(with pet: Pet) {
        
        kindLabel.text = pet.kind
        
        varietyLabel.text = pet.variety
        
        organizationLabel.text = pet.shelterName
        
        photoImageView.loadImage(pet.photoURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        if pet.sex == "M" {
            
            sexLabel.text = "♂"
            
            sexLabel.textColor = UIColor.maleColor
            
        } else {
            
            sexLabel.text = "♀"
            
            sexLabel.textColor = UIColor.femaleColor
        }
        
        if pet.sterilization == "T" {
            
            sterilizationLabel.text = "已結紮"
            
        } else {
            
            sterilizationLabel.text = "未結紮"
        }
        
        if pet.bacterin == "T" {
            
            bacterinLabel.text = "已注射疫苗"
            
        } else {
            
            bacterinLabel.text = "未注射疫苗"
        }
    }
}
