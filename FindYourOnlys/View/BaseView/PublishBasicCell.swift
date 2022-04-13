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
}

class PublishBasicCell: UITableViewCell {
    
    weak var delegate: PublishBasicCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //Implement by child class
    func layoutCell() {

    }
    func layoutCell(category: String) {

    }
    
    func passValue() {
        
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
}
