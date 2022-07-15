//
//  AdoptTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit

class AdoptCollectionViewCell: TransformCollectionCell {
    
    // MARK: - Properties
    
    @IBOutlet private weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .white
        }
    }
    
    @IBOutlet private weak var photoImageView: UIImageView! {
        
        didSet {
            
            photoImageView.tintColor = .systemGray2
            
            photoImageView.backgroundColor = .white
        }
    }
    
    @IBOutlet private weak var cityLabel: UILabel! {
        
        didSet {
            
            cityLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            cityLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            
            kindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var sexLabel: UILabel! {
        
        didSet {
            
            sexLabel.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
            
            sexLabel.textColor = .projectIconColor3
        }
    }
    
    @IBOutlet private weak var locationImageView: UIImageView! {
        
        didSet {
            
            locationImageView.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var varietyLabel: UILabel!
    
    @IBOutlet private weak var idLabel: UILabel!
    
    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseView.layer.cornerRadius = 12
        
        photoImageView.layer.cornerRadius = 12
    }
    
    func configureCell(with pet: Pet) {
        
        let location = pet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = pet.kind
        
        photoImageView.loadImage(pet.photoURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        if pet.sex == "M" {
            
            sexLabel.text = "♂"
            
            sexLabel.textColor = .maleColor
            
        } else {
            
            sexLabel.text = "♀"
            
            sexLabel.textColor = .femaleColor
        }
    }
}
