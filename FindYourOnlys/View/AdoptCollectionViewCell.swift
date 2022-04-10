//
//  AdoptTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
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
    
    var addToFavoriteHandler: (() -> Void)?
    
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
    
    @IBAction func addToFavorite(_ sender: UIButton) {
        
        addToFavoriteHandler?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        addToFavoriteHandler = nil
    }
}
