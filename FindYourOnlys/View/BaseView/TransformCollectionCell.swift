//
//  TransformCollectionCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/14.
//

import Foundation
import UIKit

class TransformCollectionCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        
        didSet {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                
                self.transform = self.isSelected
                ? CGAffineTransform(scaleX: 0.7, y: 0.7)
                : CGAffineTransform.identity
            }
        }
    }
    
    override var isHighlighted: Bool {
        
        didSet {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                
                self.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.9, y: 0.9)
                : CGAffineTransform.identity
            }
        }
    }
}
