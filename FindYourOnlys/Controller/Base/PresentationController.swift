//
//  PresentationController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import UIKit

class PresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        CGRect(
            origin: CGPoint(x: 0, y: self.containerView!.frame.height * 0.4),
            size: CGSize(
                width: containerView!.frame.width,
                height: containerView!.frame.height * 0.6
            )
        )
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        let blurEffect = UIBlurEffect(style: .dark)
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.blurEffectView.isUserInteractionEnabled = true
        
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func presentationTransitionWillBegin() {
        
        blurEffectView.alpha = 0
        
        containerView?.addSubview(blurEffectView)
        
        presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { _ in

            self.blurEffectView.alpha = 0.7
                
        }, completion: { _ in })
    }
    
    override func dismissalTransitionWillBegin() {
        
        self.presentedViewController.transitionCoordinator?
            .animate(alongsideTransition: { _ in
            
            self.blurEffectView.alpha = 0
            
        }, completion: { _ in
            
            self.blurEffectView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
      presentedView!.roundCorners(corners: [.topLeft, .topRight], radius: 22)
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        presentedView?.frame = frameOfPresentedViewInContainerView
        
        blurEffectView.frame = containerView!.bounds
    }

    @objc func dismissController() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
