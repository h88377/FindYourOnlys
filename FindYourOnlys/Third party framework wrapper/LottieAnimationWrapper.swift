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
}

class LottieAnimationWrapper {
    
    static let shared = LottieAnimationWrapper()
    
    private let loadingView = AnimationView(name: LottieName.loading.rawValue)
    
    private let scanView = AnimationView(name: LottieName.imageScan.rawValue)
    
    private lazy var blurView = UIView()
    
    func startLoading() {
        
        let width = UIScreen.main.bounds.width
        
        let height = UIScreen.main.bounds.height
        
        let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        
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
        
        let width = UIScreen.main.bounds.width
        
        let height = UIScreen.main.bounds.height
        
        let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        
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
    
}
