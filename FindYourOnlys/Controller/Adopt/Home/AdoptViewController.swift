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

class AdoptViewController: BaseViewController {
    
    private enum AdoptButtonType: String {
        
        case adopt = "領養列表"
        
        case favorite = "我的最愛"
    }
    
    private struct Segue {
        
        static let favorite = "SegueFavorite"
        
        static let list = "SegueList"
    }
    
    weak var delegate: AdoptViewControllerDelegate?
    
    var adoptListVC: AdoptListViewController?
    
    let viewModel = AdoptViewModel()
    
    @IBOutlet weak var indicatorView: UIView! {
        
        didSet {
            
            indicatorView.backgroundColor = .black
        }
    }
    
    @IBOutlet weak var indicatorCenterXConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var adoptListContainerView: UIView!
    
    @IBOutlet weak var adoptFavoriteContainerView: UIView!
    
    @IBOutlet weak var adoptListButton: UIButton! {
        
        didSet {
            
            adoptListButton.setTitleColor(.white, for: .selected)
            
            adoptListButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            
            adoptListButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet var adoptButtons: [UIButton]! {
        
        didSet {
            
            adoptButtons.forEach {
                
                $0.setTitleColor(.systemGray2, for: .normal)
                
                $0.setTitleColor(.white, for: .selected)
            }
        }
    }
    
    var containerViews: [UIView] {
        
        [adoptListContainerView, adoptFavoriteContainerView]
    }
    
    @IBOutlet weak var filterButton: UIBarButtonItem! {
        
        didSet {
            
            filterButton.tintColor = .projectIconColor1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            if
                let error = errorViewModel?.error {
                
                DispatchQueue.main.async {
                    
                    if
                        let firebaseError = error as? FirebaseError {
                        
                        self?.showAlertWindow(title: "異常", message: "\(firebaseError.errorMessage)")
                        
                    }   
                }
            }
        }
        
        viewModel.fetchCurrentUser()
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "領養資訊"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.favorite {
            
            let adoptFavoriteVC = segue.destination as? AdoptFavoriteViewController
            
            self.delegate = adoptFavoriteVC
            
        } else {
            
            let adoptListVC = segue.destination as? AdoptListViewController
            
            self.adoptListVC = adoptListVC
        }
    }
    
    @IBAction func pressAdoptButton(_ sender: UIButton) {
        
        adoptButtons.forEach {
            
            $0.isSelected = false
            
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            
            $0.backgroundColor = .white
        }
        
        sender.isSelected = true
        
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        
        sender.backgroundColor = .projectIconColor1
        
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
    
    @IBAction func goToFilter(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptFilterLocationVC = storyboard.instantiateViewController(
                withIdentifier: AdoptFilterViewController.identifier)
                as? AdoptFilterViewController
        
        else { return }
        
        navigationController?.pushViewController(adoptFilterLocationVC, animated: true)
    }
}
