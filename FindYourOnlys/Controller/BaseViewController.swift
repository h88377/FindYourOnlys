//
//  BaseViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit
import IQKeyboardManagerSwift

class BaseViewController: UIViewController {
    
    var isHiddenTabBar: Bool {
        
        return false
    }

    var isHiddenNavigationBar: Bool {
        
        return false
    }
    
    var isEnableResignOnTouchOutside: Bool {

        return true
    }

    var isEnableIQKeyboard: Bool {

        return true
    }
    
    var isHiddenIQKeyboardToolBar: Bool {

        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        
        setupNavigationTitle()
        
        setupTableView()
        
        view.backgroundColor = .systemGray6
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isHiddenTabBar {
            
            tabBarController?.tabBar.isHidden = true
        }
        
        if isHiddenNavigationBar {
            
            navigationController?.navigationBar.isHidden = true
        }
        
        if !isEnableIQKeyboard {
            
            IQKeyboardManager.shared.enable = false
            
        } else {
            
            IQKeyboardManager.shared.enable = true
        }

        if !isEnableResignOnTouchOutside {
            
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
            
        } else {
            
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        }
        
        if isHiddenIQKeyboardToolBar {
            
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isHiddenTabBar {
            
            tabBarController?.tabBar.isHidden = false
        }
        
        if isHiddenNavigationBar {
            
            navigationController?.navigationBar.isHidden = false
        }
        
        if !isEnableIQKeyboard {
            
            IQKeyboardManager.shared.enable = true
            
        } else {
            
            IQKeyboardManager.shared.enable = false
        }

        if !isEnableResignOnTouchOutside {
            
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
            
        } else {
            
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        }
        
        if isHiddenIQKeyboardToolBar {
            
            IQKeyboardManager.shared.enableAutoToolbar = true
        }
    }
    
    func setupNavigationTitle() {

        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.projectTextColor]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes

//        navigationController?.navigationBar.backgroundColor = .systemPurple
        
    }
    
    func setupTableView() {
        
        
    }
    
    func setupCollectionView() {


    }
    
    func showAlertWindow(title: String, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension BaseViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController)
    -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
