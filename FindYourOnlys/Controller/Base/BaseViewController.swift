//
//  BaseViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/14.
//

import UIKit
import IQKeyboardManagerSwift
import AudioToolbox.AudioServices

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    
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
    
    // MARK: - Life cycle
    
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
    
    // MARK: - Methods
    
    func setupNavigationTitle() {

        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.projectTextColor]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func setupTableView() {
        
    }
    
    func setupCollectionView() {

    }
    
    func showAlertWindow(title: String, message: String?) {
        
        DispatchQueue.main.async { [weak self] in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .default)
            
            alert.addAction(action)
            
            self?.present(alert, animated: true)
        }
    }
    
    func configureIpadAlert(with alert: UIAlertController) {
        
        alert.popoverPresentationController?.sourceView = self.view
        
        let xOrigin = self.view.bounds.width / 2
        
        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
        
        alert.popoverPresentationController?.sourceRect = popoverRect
        
        alert.popoverPresentationController?.permittedArrowDirections = .up
    }
    
    func startLoading() {
        
        DispatchQueue.main.async {

            LottieAnimationWrapper.shared.startLoading()
        }
    }
    
    func stopLoading() {
        
        DispatchQueue.main.async {

            LottieAnimationWrapper.shared.stopLoading()
        }
    }
    
    func startScanning() {
        
        DispatchQueue.main.async {

            LottieAnimationWrapper.shared.startScanning()
        }
    }
    
    func stopScanning() {
        
        DispatchQueue.main.async {

            LottieAnimationWrapper.shared.stopScanning()
        }
    }
    
    func success() {
        
        DispatchQueue.main.async {

            LottieAnimationWrapper.shared.success()
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func addToFavorite() {
        
        DispatchQueue.main.async {

            LottieAnimationWrapper.shared.addToFavorite()
        }
        
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
