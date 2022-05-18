//
//  UIView+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import Foundation
import UIKit

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func makeRound() {
        
        self.layer.cornerRadius = self.frame.height / 2
    }
}
