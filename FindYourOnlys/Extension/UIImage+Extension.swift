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
    
    case shareSocietyItem = "person.2"
    
    case shareSocietySelectedItem = "person.2.fill"
    
    case profileItem = "person"
    
    case profileSelectedItem = "person.fill"
    
    // PlaceHolder
    case personPlaceHolder = "person.circle"
    
    case messagePlaceHolder = "questionmark.folder"
    
    case petPlaceHolder = "questionmark.circle"
    
    // Favorite
    
    case addToFavorite = "heart"
    
    case removeFromFavorite = "heart.fill"
    
    case search = "magnifyingglass"
}

enum ImageAsset: String {
    
    case cat
    
    case dog
    
    case others
}

// swiftlint:enable identifier_name

extension UIImage {
    
    static func system(_ system: SystemImageAsset) -> UIImage? {

        return UIImage(systemName: system.rawValue)
    }
    
    static func asset(_ name: ImageAsset) -> UIImage? {
        
        return UIImage(named: name.rawValue)
    }
}
