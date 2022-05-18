//
//  FavoriteCollectionViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            
            kindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var sexLabel: UILabel! {
        
        didSet {
            
            sexLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
            
            sexLabel.textColor = .projectIconColor3
        }
    }
    
    @IBOutlet weak var varietyLabel: UILabel! {
        
        didSet {
            
            varietyLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var locationImageView: UIImageView! {
        
        didSet {
            
            locationImageView.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var bacterinLabel: UILabel! {
        
        didSet {
            
            bacterinLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var sterilizationLabel: UILabel! {
        
        didSet {
            
            sterilizationLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var organizationLabel: UILabel! {
        
        didSet {
            
            organizationLabel.textColor = .projectTextColor
        }
    }
    
    // MARK: - Life cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        photoImageView.layer.cornerRadius = 15
        
        baseView.layer.cornerRadius = 15
    }
    
    // MARK: - Methods
    
    func configureCell(with viewModel: PetViewModel) {
        
        kindLabel.text = viewModel.pet.kind
        
        varietyLabel.text = viewModel.pet.variety
        
        organizationLabel.text = viewModel.pet.shelterName
        
        photoImageView.loadImage(viewModel.pet.photoURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        if viewModel.pet.sex == "M" {
            
            sexLabel.text = "♂"
            
            sexLabel.textColor = UIColor.maleColor
            
        } else {
            
            sexLabel.text = "♀"
            
            sexLabel.textColor = UIColor.femaleColor
        }
        
        if viewModel.pet.sterilization == "T" {
            
            sterilizationLabel.text = "已結紮"
            
        } else {
            
            sterilizationLabel.text = "未結紮"
        }
        
        if viewModel.pet.bacterin == "T" {
            
            bacterinLabel.text = "已注射疫苗"
            
        } else {
            
            bacterinLabel.text = "未注射疫苗"
        }
    }
}
