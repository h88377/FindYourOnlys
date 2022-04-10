//
//  FavoriteCollectionViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var varietyLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    func configureCell(with viewModel: PetViewModel) {
        
        let location = viewModel.pet.address
        
        locationLabel.text = String(location[...2])
        
        kindLabel.text = viewModel.pet.kind
        
        sexLabel.text = viewModel.pet.sex
        
        varietyLabel.text = viewModel.pet.variety
        
        idLabel.text = "\(viewModel.pet.id)"
        
        statusLabel.text = viewModel.pet.status
        
        photoImageView.loadImage(viewModel.pet.photoURLString)
    }

}
