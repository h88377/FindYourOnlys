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
    
    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var varietyLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    func configureCell(with viewModel: FavoriteLSPetViewModel) {
        
        let location = viewModel.lsPet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.lsPet.kind
        
        varietyLabel.text = viewModel.lsPet.variety
        
        idLabel.text = "\(viewModel.lsPet.id)"
        
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
        
        idLabel.text = "\(viewModel.pet.id)"
        
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
}
