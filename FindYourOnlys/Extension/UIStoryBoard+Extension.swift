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
    
    static let shareSociety = "ShareSociety"
    
    static let auth = "Auth"
}

extension UIStoryboard {

    static var adopt: UIStoryboard { return getStoryboard(name: StoryboardCategory.adopt) }

    static var findPetSociety: UIStoryboard { return getStoryboard(name: StoryboardCategory.findPetSociety) }
    
    static var profile: UIStoryboard { return getStoryboard(name: StoryboardCategory.profile) }
    
    static var shareSociety: UIStoryboard { return getStoryboard(name: StoryboardCategory.shareSociety) }
    
    static var auth: UIStoryboard { return getStoryboard(name: StoryboardCategory.auth) }

    private static func getStoryboard(name: String) -> UIStoryboard {

        return UIStoryboard(name: name, bundle: nil)
    }
}
