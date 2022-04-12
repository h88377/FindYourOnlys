//
//  AdoptViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/8.
//

import UIKit

protocol AdoptViewControllerDelegate: AnyObject {
    
    func fetchFavoritePet()
}

class AdoptViewController: UIViewController {
    
    private enum AdoptButtonType: String {
        
        case adopt = "領養列表"
        
        case favorite = "我的最愛"
    }
    
    private struct Segue {
        
        static let favorite = "SegueFavorite"
    }
    
    weak var delegate: AdoptViewControllerDelegate?
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            segue.identifier == Segue.favorite,
            let adpotFavoriteVC = segue.destination as? AdoptFavoriteViewController
                
        else { return }
        
        self.delegate = adpotFavoriteVC
    }
    
    @IBAction func pressAdoptButton(_ sender: UIButton) {
        
        adoptButtons.forEach { $0.isSelected = false }
        
        sender.isSelected = true
        
        moveIndicatorView(to: sender)
        
        guard
            let currentTitle = sender.currentTitle,
            let type = AdoptButtonType(rawValue: currentTitle) else { return }
        
        updateContainerView(with: type)
        
        if type == .favorite {
        
            delegate?.fetchFavoritePet()
        }
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
