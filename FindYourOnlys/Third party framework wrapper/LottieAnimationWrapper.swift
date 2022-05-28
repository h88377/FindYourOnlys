//
//  LottieAnimationWrapper.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/2.
//

import Foundation
import Lottie
import UIKit

enum LottieName: String {
    
    case loading
    
    case ladyCat
    
    case manCat
    
    case curiousCat
    
    case imageScan
    
    case success
    
    case addToFavorite
}

class LottieAnimationWrapper {
    
    // MARK: - Properties
    
    static let shared = LottieAnimationWrapper()
    
    private init() { }
    
    private let loadingView = AnimationView(name: LottieName.loading.rawValue)
    
    private let scanView = AnimationView(name: LottieName.imageScan.rawValue)
    
    private let successView = AnimationView(name: LottieName.success.rawValue)
    
    private let addToFavoriteView = AnimationView(name: LottieName.addToFavorite.rawValue)
    
    private lazy var blurView = UIView()
    
    private let width = UIScreen.main.bounds.width
    
    private let height = UIScreen.main.bounds.height
    
    private let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    
    // MARK: - Methods
    
    func startLoading() {
        
        blurView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        blurView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        currentWindow?.addSubview(blurView)
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        
        loadingView.center = currentWindow!.center
        
        loadingView.contentMode = .scaleAspectFill
        
        currentWindow?.addSubview(loadingView)
        
        loadingView.play()
        
        loadingView.loopMode = .loop
    }
    
    func stopLoading() {
        
        loadingView.removeFromSuperview()

        blurView.removeFromSuperview()
        
        loadingView.stop()
    }
    
    func startScanning() {
        
        blurView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        currentWindow?.addSubview(blurView)
        
        scanView.frame = CGRect(x: 0, y: 0, width: width, height: height / 2)
        
        scanView.center = currentWindow!.center
        
        scanView.contentMode = .scaleAspectFill
        
        currentWindow?.addSubview(scanView)
        
        scanView.play()
        
        scanView.loopMode = .loop
        
    }
    
    func stopScanning() {
        
        scanView.removeFromSuperview()

        blurView.removeFromSuperview()
        
        loadingView.stop()
    }
    
    func success() {
        
        successView.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        
        successView.center = currentWindow!.center
        
        successView.contentMode = .scaleAspectFill
        
        currentWindow?.addSubview(successView)
        
        successView.play()
        
        successView.loopMode = .loop
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            
            self?.successView.removeFromSuperview()
        }
    }
    
    func addToFavorite() {
        
        addToFavoriteView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        
        addToFavoriteView.center = currentWindow!.center
        
        addToFavoriteView.contentMode = .scaleAspectFill
        
        currentWindow?.addSubview(addToFavoriteView)
        
        addToFavoriteView.play()
        
        addToFavoriteView.loopMode = .loop
        
        addToFavoriteView.animationSpeed = 1
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) { [weak self] in
            
            self?.addToFavoriteView.removeFromSuperview()
        }
    }
    
}
