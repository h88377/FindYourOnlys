//
//  PopAnimator.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/5/14.
//

import Foundation

import UIKit

final class PopAnimator: NSObject {
    
    var originFrame = CGRect()
    
    private let duration: TimeInterval = 0.5
    
//    var presenting = true
    
}

extension PopAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
      //1) Set up transition
      let containerView = transitionContext.containerView

      guard let toView = transitionContext.view(forKey: .to)
      else { return }

      let initialFrame = originFrame
      let finalFrame = toView.frame

      toView.transform = .init(
        scaleX: initialFrame.width / finalFrame.width,
        y: initialFrame.height / finalFrame.height
      )
      toView.center = .init(x: initialFrame.midX, y: initialFrame.midY)

      containerView.addSubview(toView)

      //2) Animate!
      UIView.animate(
        withDuration: duration, delay: 0,
        usingSpringWithDamping: 1,
        initialSpringVelocity: 0,
        animations: {
          toView.transform = .identity
          toView.center = .init(x: finalFrame.midX, y: finalFrame.midY)
        },
        completion: { _ in
          transitionContext.completeTransition(true)
        }
      )
    }
    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        //1) Set up transition
//        let containerView = transitionContext.containerView
//
//        guard let animalCell = transitionContext.view(forKey: presenting ? .to : .from)
//
//        else { return }
//
//        let (initialFrame, finalFrame) =
//        presenting
//        ? (originFrame, animalCell.frame)
//        : (animalCell.frame, originFrame)
//
//        let scaleTransform =
//        presenting
//        ? CGAffineTransform(
//            scaleX: initialFrame.width / finalFrame.width,
//            y: initialFrame.height / finalFrame.height
//        )
//        : .init(
//            scaleX: finalFrame.width / initialFrame.width,
//            y: finalFrame.height / initialFrame.height
//        )
//
//        if presenting {
//            animalCell.transform = scaleTransform
//            animalCell.center = .init(x: initialFrame.midX, y: initialFrame.midY)
//        }
//
//        animalCell.layer.cornerRadius = presenting ? 20 / scaleTransform.a : 0
//        animalCell.clipsToBounds = true
//
//        if let toView = transitionContext.view(forKey: .to) {
//            containerView.addSubview(toView)
//        }
//
//        containerView.bringSubviewToFront(animalCell)
//
////        guard let adoptDetailContainer =
////                ( transitionContext.viewController(forKey: presenting ? .to : .from)
////                  as? AdoptDetailViewController
////                )?.containerView
////        else { return }
////
////        if presenting {
////            adoptDetailContainer.alpha = 0
////        }
//
//        //2) Animate!
//        UIView.animate(
//            withDuration: duration,
//            delay: 0,
//            usingSpringWithDamping: 1,
//            initialSpringVelocity: 0,
//            animations: {
//                animalCell.layer.cornerRadius = self.presenting ? 0 : 20 / scaleTransform.a
//                animalCell.transform = self.presenting ? .identity : scaleTransform
//                animalCell.center = .init(x: finalFrame.midX, y: finalFrame.midY)
////                adoptDetailContainer.alpha = self.presenting ? 1 : 0
//            },
//            completion: { _ in
//                //3) Complete transition
//                if !self.presenting {
//                    (transitionContext.viewController(forKey: .to) as? AdoptListViewController)
////                        .selectedImage.alpha = 1
//                }
//                transitionContext.completeTransition(true)
//            }
//        )
//    }
}
