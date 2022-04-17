//
//  UIImage+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

enum SystemImageAsset: String {

    // Profile tab - Tab
    case adoptItem = "doc.fill"
    
    case adoptSelectedItem = "doc.text.image.fill"
    
    case findPetSocietyItem = "person.3"
    
    case findPetSocietySelectedItem = "person.3.fill"
    
    case personPlaceHolder = "person.circle"
    
    case messagePlaceHolder = "questionmark.folder"
    
    case petPlaceHolder = "questionmark.circle"
    
}

// swiftlint:enable identifier_name

extension UIImage {
    
    static func system(_ system: SystemImageAsset) -> UIImage? {

        return UIImage(systemName: system.rawValue)
    }
}