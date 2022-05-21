//
//  TransformButton.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/14.
//

import Foundation
import UIKit

class TransformButton: UIButton {
    
    override var isHighlighted: Bool {
        
        didSet {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut) {
                
                self.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.8, y: 0.8)
                : CGAffineTransform.identity
            }
        }
    }
}
