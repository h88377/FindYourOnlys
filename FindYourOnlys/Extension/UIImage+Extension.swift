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
    
    // Society
    
    case search = "magnifyingglass"
    
    case addFriend = "person.badge.plus"
}

enum ImageAsset: String {
    
    case cat
    
    case dog
    
    case others
    
    case location
    
    case rightArrow
    
    case edit
    
    case chatSocietyItem = "chat"
    
    case chatSocietySelectedItem = "selectedChat"
    
    case findYourOnlysPlaceHolder = "FYOsPlaceHolder"
    
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
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
