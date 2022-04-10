//
//  AdoptTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class AdoptCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var kindLabel: UILabel!
    
    @IBOutlet weak var sexLabel: UILabel!
    
    @IBOutlet weak var varietyLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    func configureCell(with viewModel: PetViewModel) {
        
        locationLabel.text = viewModel.pet.location
        
        kindLabel.text = viewModel.pet.kind
        
        sexLabel.text = viewModel.pet.sex
        
        varietyLabel.text = viewModel.pet.variety
        
        idLabel.text = "\(viewModel.pet.id)"
        
        statusLabel.text = viewModel.pet.status
    }
}
