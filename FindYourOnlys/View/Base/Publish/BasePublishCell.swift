//
//  BaseTableViewCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/13.
//

import UIKit

protocol BasePublishCellDelegate: AnyObject {
    
    func didChangeCity(_ cell: BasePublishCell, with city: String)
    
    func didChangeColor(_ cell: BasePublishCell, with color: String)
    
    func didChangePetKind(_ cell: BasePublishCell, with petKind: String)
    
    func didChangePostType(_ cell: BasePublishCell, with postType: String)
    
    func didChangeContent(_ cell: BasePublishCell, with content: String)
    
    func didChangeSex(_ cell: BasePublishCell, with sex: String)
}

class BasePublishCell: UITableViewCell {
    
    // MARK: - Properties
    
    weak var delegate: BasePublishCellDelegate?
    
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

// MARK: - BasePublishCellDelegate

extension BasePublishCellDelegate {
    
    func didChangeCity(_ cell: BasePublishCell, with city: String) {
        
    }
    
    func didChangeColor(_ cell: BasePublishCell, with color: String) {
        
    }
    
    func didChangePetKind(_ cell: BasePublishCell, with petKind: String) {
        
    }
    
    func didChangePostType(_ cell: BasePublishCell, with postType: String) {
        
    }
    
    func didChangeContent(_ cell: BasePublishCell, with content: String) {
        
    }
    
    func didChangeSex(_ cell: BasePublishCell, with sex: String) {
        
    }
}
