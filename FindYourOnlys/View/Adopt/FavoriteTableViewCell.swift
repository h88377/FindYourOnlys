//
//  FavoriteCollectionViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var baseBackgroundView: UIView!
    
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
            
            sexLabel.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
            
            sexLabel.textColor = .projectIconColor3
        }
    }
    
    @IBOutlet weak var varietyLabel: UILabel! {
        
        didSet {
            
            varietyLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel!  {
        
        didSet {
            
            statusLabel.textColor = .projectTextColor
            
            statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
    }
    
    @IBOutlet weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var locationImageView: UIImageView!  {
        
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
    
    func configureCell(with viewModel: FavoriteLSPetViewModel) {
        
        let location = viewModel.lsPet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.lsPet.kind
        
        varietyLabel.text = viewModel.lsPet.variety
        
        photoImageView.loadImage(viewModel.lsPet.photoURLString, placeHolder: UIImage.asset(.findYourOnlysPlaceHolder))
        
        organizationLabel.text = viewModel.lsPet.shelterName
        
        if viewModel.lsPet.status == "OPEN" {
            
            statusLabel.text = "開放認養"
            
//            statusLabel.textColor = .openAdopt
            
        } else {
            
            statusLabel.text = "不開放認養"
            
//            statusLabel.textColor = .closeAdopt
        }
        
        if viewModel.lsPet.sex == "M" {
            
            sexLabel.text = "♂"
            
            sexLabel.textColor = UIColor.maleColor
            
        } else {
            
            sexLabel.text = "♀"
            
            sexLabel.textColor = UIColor.femaleColor
        }
        
        if viewModel.lsPet.sterilization == "T" {
            
            sterilizationLabel.text = "已結紮"
            
        } else {
            
            sterilizationLabel.text = "未結紮"
        }
        
        if viewModel.lsPet.bacterin == "T" {
            
            bacterinLabel.text = "已注射疫苗"
            
        } else {
            
            bacterinLabel.text = "未注射疫苗"
        }
    }
    
    func configureCell(with viewModel: PetViewModel) {
        
        let location = viewModel.pet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.pet.kind
        
        varietyLabel.text = viewModel.pet.variety
        
        organizationLabel.text = viewModel.pet.shelterName
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        photoImageView.layer.cornerRadius = 15
        
        baseView.layer.cornerRadius = 15
        
//        baseView.layer.shadowColor = UIColor.black.cgColor
//        baseView.layer.shadowOpacity = 0.1
//        baseView.layer.shadowOffset = .zero
//        baseView.layer.shadowRadius = 5
//        baseView.layer.shadowPath = UIBezierPath(rect: baseView.bounds).cgPath
//        baseView.layer.shouldRasterize = true
//        baseView.layer.rasterizationScale = UIScreen.main.scale
    }
}
