//
//  UIStoryBoard+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

private struct StoryboardCategory {

    static let adopt = "Adopt"

    static let findPetSociety = "FindPetSociety"
    
    static let profile = "Profile"
}

extension UIStoryboard {

    static var adopt: UIStoryboard { return getStoryboard(name: StoryboardCategory.adopt) }

    static var findPetSociety: UIStoryboard { return getStoryboard(name: StoryboardCategory.findPetSociety) }
    
    static var profile: UIStoryboard { return getStoryboard(name: StoryboardCategory.profile) }

    private static func getStoryboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
