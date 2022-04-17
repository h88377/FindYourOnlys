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
}

class PublishBasicCell: UITableViewCell {
    
    weak var delegate: PublishBasicCellDelegate?
    
    var cameraHandler: (() ->Void)?
    
    var galleryHandler: (() ->Void)?

    // Implement by child class
    func layoutCell() {

    }
    func layoutCell(category: String) {

    }
    
    func layoutCellWith(image: UIImage) {
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cameraHandler = nil
        
        galleryHandler = nil
    }
    
}

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
}