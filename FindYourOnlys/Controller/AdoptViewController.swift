//
//  AdoptViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/8.
//

import UIKit

class AdoptViewController: UIViewController {
    
    private enum AdoptButtonType: String {
        
        case adopt = "領養列表"
        
        case favorite = "我的最愛"
    }
    
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var indicatorCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var adoptListContainerView: UIView!
    
    @IBOutlet weak var adoptFavoriteContainerView: UIView!
    
    @IBOutlet var adoptButtons: [UIButton]! {
        
        didSet {
            
            adoptButtons.forEach {
                
                $0.setTitleColor(.systemGray2, for: .normal)
                
                $0.setTitleColor(.black, for: .selected)
            }
        }
    }
    
    var containerViews: [UIView] {
        
        [adoptListContainerView, adoptFavoriteContainerView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func pressAdoptButton(_ sender: UIButton) {
        
        adoptButtons.forEach { $0.isSelected = false }
        
        sender.isSelected = true
        
        moveIndicatorView(to: sender)
        
        guard
            let currentTitle = sender.currentTitle,
            let type = AdoptButtonType(rawValue: currentTitle) else { return }
        
        updateContainerView(with: type)
    }
    
    private func moveIndicatorView(to sender: UIView) {

        indicatorCenterXConstraint.isActive = false

        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)

        indicatorCenterXConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in

            self?.view.layoutIfNeeded()
        })
    }
    
    private func updateContainerView(with type: AdoptButtonType) {
        
        containerViews.forEach { $0.isHidden = true }
        
        switch type {
            
        case .adopt:
            
            adoptListContainerView.isHidden = false
            
        case .favorite:
            
            adoptFavoriteContainerView.isHidden = false
        }
    }
}
