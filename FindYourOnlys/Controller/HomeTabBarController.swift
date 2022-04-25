//
//  HomeTabBarViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

private enum Tab: CaseIterable {

    case adopt
    
    case findPetSociety
    
    case shareSociety

    case profile
    
    func controller() -> UIViewController {

        var controller: UIViewController

        switch self {

        case .adopt:
            
            controller = UIStoryboard.adopt.instantiateInitialViewController()!

        case .findPetSociety:
            
            controller = UIStoryboard.findPetSociety.instantiateInitialViewController()!
            
        case .profile:
            
            controller = UIStoryboard.profile.instantiateInitialViewController()!
        
        case .shareSociety:
            
            controller = UIStoryboard.shareSociety.instantiateInitialViewController()!
        }

        controller.tabBarItem = tabBarItem()

        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: -6.0, right: 0.0)

        return controller
    }

    func tabBarItem() -> UITabBarItem {

        switch self {

        case .adopt:
            
            return UITabBarItem(
                title: nil,
                image: UIImage.system(.adoptItem),
                selectedImage: UIImage.system(.adoptSelectedItem)
            )

        case .findPetSociety:
            return UITabBarItem(
                title: nil,
                image: UIImage.system(.findPetSocietyItem),
                selectedImage: UIImage.system(.findPetSocietySelectedItem)
            )
        case .shareSociety:
            return UITabBarItem(
                title: nil,
                image: UIImage.system(.shareSocietyItem),
                selectedImage: UIImage.system(.shareSocietySelectedItem)
            )
            
        case .profile:
            return UITabBarItem(
                title: nil,
                image: UIImage.system(.profileItem),
                selectedImage: UIImage.system(.profileSelectedItem)
            )
        }
    }
}

class HomeTabBarController: UITabBarController {
    
    private let tabs: [Tab] = Tab.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = tabs.map({ $0.controller() })
        
    }
}
