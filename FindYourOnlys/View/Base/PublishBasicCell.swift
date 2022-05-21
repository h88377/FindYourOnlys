//
//  BaseTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

protocol PublishBasicCellDelegate: AnyObject {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String)
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String)
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String)
    
    func didChangePostType(_ cell: PublishBasicCell, with postType: String)
    
    func didChangeContent(_ cell: PublishBasicCell, with content: String)
    
    func didChangeSex(_ cell: PublishBasicCell, with sex: String)
}

class PublishBasicCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: PublishBasicCellDelegate?
    
    var cameraHandler: (() -> Void)?
    
    var galleryHandler: (() -> Void)?
    
    var imageDetectHandler: (() -> Void)?
    
    // MARK: - Methods
    
    // Implement by child class
    func layoutCell(article: Article? = nil) {
        
    }
    
    func layoutCell(category: String) {
        
    }
    
    func layoutCell(category: String, article: Article? = nil) {
        
    }
    
    func layoutCell(category: String, condition: AdoptFilterCondition? = nil) {
        
    }
    
    func layoutCell(category: String, findCondition: FindPetSocietyFilterCondition? = nil) {
        
    }
    
    func layoutCellWith(image: UIImage) {
        
    }
    
    // MARK: - View Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cameraHandler = nil
        
        galleryHandler = nil
        
        imageDetectHandler = nil
    }
    
}

// MARK: - PublishBasicCellDelegate

extension PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
        
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
    }
    
    func didChangePostType(_ cell: PublishBasicCell, with postType: String) {
        
    }
    
    func didChangeContent(_ cell: PublishBasicCell, with content: String) {
        
    }
    
    func didChangeSex(_ cell: PublishBasicCell, with sex: String) {
        
    }
}
