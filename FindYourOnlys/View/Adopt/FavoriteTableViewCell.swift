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
        
        sexLabel.text = viewModel.lsPet.sex
        
        varietyLabel.text = viewModel.lsPet.variety
        
        idLabel.text = "\(viewModel.lsPet.id)"
        
        statusLabel.text = viewModel.lsPet.status
        
        photoImageView.loadImage(viewModel.lsPet.photoURLString)
    }
    
    func configureCell(with viewModel: PetViewModel) {
        
        let location = viewModel.pet.address
        
        cityLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.pet.kind
        
        sexLabel.text = viewModel.pet.sex
        
        varietyLabel.text = viewModel.pet.variety
        
        idLabel.text = "\(viewModel.pet.id)"
        
        statusLabel.text = viewModel.pet.status
        
        photoImageView.loadImage(viewModel.pet.photoURLString)
    }
}
