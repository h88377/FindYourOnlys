//
//  UIImage+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

enum SystemImageAsset: String {

    // Profile tab - Tab
    case adoptItem = "house"
    
    case adoptSelectedItem = "house.fill"
    
    case findPetSocietyItem = "magnifyingglass.circle"
    
    case findPetSocietySelectedItem = "magnifyingglass.circle.fill"
    
    case shareSocietyItem = "person.3"
    
    case shareSocietySelectedItem = "person.3.fill"
    
    case profileItem = "person.crop.circle"
    
    case profileSelectedItem = "person.crop.circle.fill"
    
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
    
    case location
    
    case rightArrow
    
    case pickerDropDown = "Icons_24px_DropDown"
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
