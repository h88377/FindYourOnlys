//
//  FavoriteCollectionViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var kindLabel: UILabel! {
        
        didSet {
            
            kindLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var varietyLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel! {
        
        didSet {
            
            statusLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
    }
    
    @IBOutlet weak var baseView: UIView!
    
    func configureCell(with viewModel: FavoriteLSPetViewModel) {
        
        let location = viewModel.lsPet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.lsPet.kind
        
        varietyLabel.text = viewModel.lsPet.variety
        
        photoImageView.loadImage(viewModel.lsPet.photoURLString)
        
        if viewModel.lsPet.status == "OPEN" {
            
            statusLabel.text = "開放認養"
            
//            statusLabel.textColor = .openAdopt
            
        } else {
            
            statusLabel.text = "不開放認養"
            
//            statusLabel.textColor = .closeAdopt
        }
        
        if viewModel.lsPet.sex == "M" {
            
            sexLabel.text = Sex.male.rawValue
            
//            sexLabel.textColor = .maleColor
            
        } else {
            
            sexLabel.text = Sex.female.rawValue
            
//            sexLabel.textColor = .femaleColor
        }
    }
    
    func configureCell(with viewModel: PetViewModel) {
        
        let location = viewModel.pet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.pet.kind
        
        varietyLabel.text = viewModel.pet.variety
        
        photoImageView.loadImage(viewModel.pet.photoURLString)
        
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
        
        photoImageView.layer.cornerRadius = 15
        
        baseView.layer.cornerRadius = 15
    }
}
