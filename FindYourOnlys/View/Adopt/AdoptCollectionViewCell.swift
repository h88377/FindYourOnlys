//
//  AdoptTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit

class AdoptCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView! {
        
        didSet {
            
            photoImageView.tintColor = .systemGray2
            
            photoImageView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var cityLabel: UILabel! {
        
        didSet {
            
            cityLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            cityLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
            
            kindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var sexLabel: UILabel! {
        
        didSet {
            
            sexLabel.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
            
            sexLabel.textColor = .projectIconColor3
        }
    }
    
    @IBOutlet weak var locationImageView: UIImageView! {
        
        didSet {
            
            locationImageView.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var varietyLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.textColor = .projectTextColor
            
            statusLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        }
    }
    
    func configureCell(with viewModel: PetViewModel) {
        
        let location = viewModel.pet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.pet.kind
        
        photoImageView.loadImage(viewModel.pet.photoURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        if viewModel.pet.status == "OPEN" {
            
            statusLabel.text = "開放認養"
            
//            statusLabel.textColor = .openAdopt
            
        } else {
            
            statusLabel.text = "不開放認養"
            
//            statusLabel.textColor = .closeAdopt
        }
        
        if viewModel.pet.sex == "M" {
            
            sexLabel.text = "♂"
            
//            sexLabel.text = Sex.male.rawValue
            
            sexLabel.textColor = .maleColor
            
        } else {
            
            sexLabel.text = "♀"
            
//            sexLabel.text = Sex.female.rawValue
            
            sexLabel.textColor = .projectIconColor3
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        baseView.layer.cornerRadius = 12
        
        photoImageView.layer.cornerRadius = 12
    }
    
}
