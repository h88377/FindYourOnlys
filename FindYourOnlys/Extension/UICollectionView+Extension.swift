//
//  UICollectionView+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func registerCellWithIdentifier(identifier: String) {
        
        let nib = UINib(nibName: identifier, bundle: nil)
        
        register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func registerHeaderViewWithIdentifier(identifier: String) {
        
        let nib = UINib(nibName: identifier, bundle: nil)
        
        register(
            nib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: identifier)
    }
    
}

extension UICollectionViewCell {
    
    static var identifier: String { return "\(self.self)"}
}

extension UICollectionReusableView {
    
    static func getIdentifier() -> String {
        
        return "\(self.self)"
    }
}
