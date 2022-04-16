//
//  UITextView+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/16.
//

import Foundation
import UIKit

extension UITextView {
    
    func centerVertically() {
        
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        
        let size = sizeThatFits(fittingSize)
        
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        
        let positiveTopOffset = max(1, topOffset)
        
        contentOffset.y = -positiveTopOffset
    }
    
}
