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
    
    // MARK: - Properties
    
    let viewModel = AdoptViewModel()
    
    weak var delegate: AdoptViewControllerDelegate?
    
    var adoptListVC: AdoptListViewController?
    
    private var containerViews: [UIView] {
        
        [adoptListContainerView, adoptFavoriteContainerView]
    }
    
    @IBOutlet private weak var adoptListContainerView: UIView!
    
    @IBOutlet private weak var adoptFavoriteContainerView: UIView!
    
    @IBOutlet private weak var adoptListButton: UIButton! {
        
        didSet {
            
            adoptListButton.setTitleColor(.white, for: .selected)
            
            adoptListButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            
            adoptListButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet private var adoptButtons: [UIButton]! {
        
        didSet {
            
            adoptButtons.forEach {
                
                $0.setTitleColor(.systemGray2, for: .normal)
                
                $0.setTitleColor(.white, for: .selected)
                
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            }
        }
    }
    
    @IBOutlet private weak var filterButton: UIBarButtonItem! {
        
        didSet {
            
            filterButton.tintColor = .projectIconColor1
            
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
        }
        
        viewModel.fetchCurrentUser()
    }
   
    // MARK: - Methods and IBActions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.favorite {
            
            let adoptFavoriteVC = segue.destination as? AdoptFavoriteViewController
            
            self.delegate = adoptFavoriteVC
            
        } else {
            
            let adoptListVC = segue.destination as? AdoptListViewController
            
            adoptListVC?.resetConditionHandler = { [weak self] in
                
                self?.viewModel.adoptFilterCondition = AdoptFilterCondition()
            }
            
            self.adoptListVC = adoptListVC
        }
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "領養資訊"
    }
    
    @IBAction func toggleAdoptButton(_ sender: UIButton) {
        
        adoptButtons.forEach {
            
            $0.isSelected = false
            
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            
            $0.backgroundColor = .systemGray6
        }
        
        sender.isSelected = true
        
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        sender.backgroundColor = .projectIconColor1
        
        guard
            let currentTitle = sender.currentTitle,
            let type = AdoptButtonType(rawValue: currentTitle) else { return }
        
        updateContainerView(with: type)
        
        if type == .favorite {
        
            delegate?.fetchFavoritePet()
            
            filterButton.isEnabled = false
            
        } else {
            
            filterButton.isEnabled = true
        }
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
            let adoptFilterVC = storyboard.instantiateViewController(
                withIdentifier: AdoptFilterViewController.identifier)
                as? AdoptFilterViewController
        
        else { return }
        
        adoptFilterVC.viewModel.adoptFilterCondition = viewModel.adoptFilterCondition
        
        navigationController?.pushViewController(adoptFilterVC, animated: true)
    }
}

// MARK: - PublishBasicCellDelegate

extension AdoptViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangeSex(_ cell: PublishBasicCell, with sex: String) {
        
        viewModel.sexChanged(with: sex)
    }
}
