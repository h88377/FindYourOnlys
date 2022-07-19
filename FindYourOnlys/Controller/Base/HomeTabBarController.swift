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
    
    case chatSociety
    
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
            
        case .chatSociety:
            
            controller = UIStoryboard.chatSociety.instantiateInitialViewController()!
        }
        
        controller.tabBarItem = tabBarItem()
        
        controller.tabBarItem.imageInsets = UIEdgeInsets(top: 6.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        return controller
    }
    
    func tabBarItem() -> UITabBarItem {
        
        switch self {
            
        case .adopt:
            
            let item = UITabBarItem(
                title: "領養",
                image: UIImage.system(.adoptItem),
                selectedImage: UIImage.system(.adoptSelectedItem))
            
            return item
            
        case .findPetSociety:
            
            let item = UITabBarItem(
                title: "協尋",
                image: UIImage.system(.findPetSocietyItem),
                selectedImage: UIImage.system(.findPetSocietySelectedItem))
            
            return item
            
        case .shareSociety:
            
            let item = UITabBarItem(
                title: "分享",
                image: UIImage.system(.shareSocietyItem),
                selectedImage: UIImage.system(.shareSocietySelectedItem))
            
            return item
            
        case .profile:
            
            let item = UITabBarItem(
                title: "個人",
                image: UIImage.system(.profileItem),
                selectedImage: UIImage.system(.profileSelectedItem))
            
            return item
            
        case .chatSociety:
            
            let chatImage = UIImage.resizeImage(
                image: UIImage.asset(.chatSocietyItem)!,
                targetSize: CGSize(width: 30, height: 30))
            
            let selectedChatImage = UIImage.resizeImage(
                image: UIImage.asset(.chatSocietySelectedItem)!,
                targetSize: CGSize(width: 30, height: 30))
            
            let item = UITabBarItem(
                title: "聊天",
                image: chatImage,
                selectedImage: selectedChatImage)
            
            return item
        }
    }
    
}

class HomeTabBarController: UITabBarController {
    
    private let tabs: [Tab] = Tab.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = tabs.map({ $0.controller() })
        
        tabBar.tintColor = .projectIconColor1
        
        delegate = self
    }
}

// MARK: - UITabBarDelegate
extension HomeTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {

        guard
            let navVC = viewController as? UINavigationController,
            navVC.viewControllers.first is ProfileViewController ||
                navVC.viewControllers.first is ChatRoomFriendListViewController
        else { return true }

        guard UserFirebaseManager.shared.currentUser != nil else {

            if let authVC = UIStoryboard.auth.instantiateInitialViewController() as? AuthViewController {

                authVC.modalPresentationStyle = .custom
                
                authVC.transitioningDelegate = self

                present(authVC, animated: true)
            }

            return false
        }

        return true
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension HomeTabBarController: UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?, source: UIViewController)
    -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
