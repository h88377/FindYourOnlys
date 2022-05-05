//
//  LottieAnimationWrapper.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/2.
//

import Foundation
import Lottie

enum LottieName: String {
    
    case loading
    
    case ladyCat
    
    case manCat
    
    case curiousCat
}

class LottieAnimationWrapper {
    
    static let shared = LottieAnimationWrapper()
    
    private let loadingView = AnimationView(name: LottieName.loading.rawValue)
    
    func startLoading(at view: UIView) {
        
        loadingView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        
        loadingView.center = view.center
        
        loadingView.contentMode = .scaleAspectFill
        
        view.addSubview(loadingView)
        
        loadingView.play()
        
        loadingView.loopMode = .loop
    }
    
    func stopLoading() {
        
        loadingView.removeFromSuperview()

        loadingView.stop()
    }
    
}
