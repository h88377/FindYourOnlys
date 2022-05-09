//
//  UIColor+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/24.
//

import UIKit

extension UIColor {
    
    static let maleColor = hexStringToUIColor(hex: "398AB9")
    
    static let femaleColor = hexStringToUIColor(hex: "ffcb65")
    
    static let openAdopt = systemGreen
    
    static let closeAdopt = systemRed
    
    static let projectPlaceHolderColor = systemGray
    
    static let projectBackgroundColor = UIColor.systemGray6
    
    static let projectBackgroundColor2 = hexStringToUIColor(hex: "f4f7f7")
    
    static let projectTextColor = UIColor.darkGray
    
    static let objectBackgroundColor = hexStringToUIColor(hex: "F2F9F1")
    
    static let projectIconColor1 = hexStringToUIColor(hex: "578c93")
    
    static let projectIconColor2 = hexStringToUIColor(hex: "98b9bd")
    
    static let projectIconColor3 = hexStringToUIColor(hex: "ffcb65")
    
    static let signInBackGroundColor = hexStringToUIColor(hex: "f3f8ee")
    
    static func hexStringToUIColor(hex: String) -> UIColor {

        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        if (cString.count) != 6 {
            return UIColor.gray
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
