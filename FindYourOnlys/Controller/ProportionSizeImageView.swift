//
//  ProportionSizeImageView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/9.
//

import Foundation
import UIKit

class ProportionSizeImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let radius: CGFloat = self.bounds.size.width / 2.0
        
        self.layer.cornerRadius = radius
    }
}
