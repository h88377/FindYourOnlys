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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationTitle()
        
        setupCollectionView()
        
        setupTableView()
        
        setupLoadingViewHandler()
        
        view.backgroundColor = .systemGray6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isHiddenNavigationBar {
            
            navigationController?.navigationBar.isHidden = true
        }
        
        if !isEnableResignOnTouchOutside {
            
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
            
        } else {
            
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        }
        
        if !isEnableIQKeyboard {
            
            IQKeyboardManager.shared.enable = false
            
        } else {
            
            IQKeyboardManager.shared.enable = true
        }
        
        if isHiddenIQKeyboardToolBar {
            
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isHiddenNavigationBar {
            
            navigationController?.navigationBar.isHidden = false
        }
        
        if !isEnableResignOnTouchOutside {
            
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
            
        } else {
            
            IQKeyboardManager.shared.enable = false
        }
        
        if !isEnableIQKeyboard {
            
            IQKeyboardManager.shared.enable = true
            
        } else {
            
            IQKeyboardManager.shared.enable = false
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
    
    func setupLoadingViewHandler() {
        
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
    
    func popBack() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func success() {
        
        DispatchQueue.main.async {

            LottieAnimationWrapper.shared.success()
        }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func addToFavoriteAnimation() {
        
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
        source: UIViewController
    ) -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
