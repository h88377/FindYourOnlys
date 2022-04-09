//
//  AdoptViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/8.
//

import UIKit

class AdoptViewController: UIViewController {
    
    @IBOutlet weak var indicatorView: UIView!
    
    @IBOutlet weak var indicatorCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet var adoptButtons: [UIButton]! {
        
        didSet {
            
            adoptButtons.forEach {
                
                $0.setTitleColor(.systemGray2, for: .normal)
                
                $0.setTitleColor(.black, for: .selected)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func setupTableView() {
        
    }
    
    @IBAction func pressAdoptButton(_ sender: UIButton) {
        
        adoptButtons.forEach { $0.isSelected = false }
        
        sender.isSelected = true
        
        moveIndicatorView(to: sender)
    }
    
    private func moveIndicatorView(to sender: UIView) {

        indicatorCenterXConstraint.isActive = false

        indicatorCenterXConstraint = indicatorView.centerXAnchor.constraint(equalTo: sender.centerXAnchor)

        indicatorCenterXConstraint.isActive = true

        UIView.animate(withDuration: 0.3, animations: { [weak self] in

            self?.view.layoutIfNeeded()
        })
    }
    
}
