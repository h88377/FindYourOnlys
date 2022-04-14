//
//  PublishMediaCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishContentCell: PublishBasicCell {
    
    @IBOutlet weak var contentImageView: UIImageView!
    
    @IBOutlet weak var contentTextView: ContentInsetTextField!
    
    @IBAction func openCamera(_ sender: UIButton) {
        
        cameraHandler?()
    }
    
    @IBAction func openGallery(_ sender: UIButton) {
        
        galleryHandler?()
    }
    
    override func layoutCellWith(image: UIImage) {
        
        contentImageView.image = image
    }
}


