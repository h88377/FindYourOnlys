//
//  UITableView+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit

extension UITableView {
    
    func registerCellWithIdentifier(identifier: String) {
        
        let nib = UINib(nibName: identifier, bundle: nil)
        
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    func registerViewWithIdentifier(identifier: String) {
        
        let nib = UINib(nibName: identifier, bundle: nil)
        
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
}

extension UITableViewCell {
    
    static var identifier: String { return "\(self.self)"}
}

extension UITableViewHeaderFooterView {
    
    static var identifier: String { return "\(self.self)"}
}
