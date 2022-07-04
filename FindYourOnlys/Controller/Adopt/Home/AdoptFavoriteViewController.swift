//
//  AdoptFavoriteViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class AdoptFavoriteViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = AdoptFavoriteViewModel()
    
    @IBOutlet private weak var remindLabel: UILabel!
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.backgroundColor = .projectBackgroundColor
            
            tableView.allowsSelection = true
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.favoritePetViewModels.bind { [weak self] favoritePetViewModels in
            
            guard
                let self = self else { return }
            
            self.tableView.reloadData()
            
            self.tableView.isHidden = favoritePetViewModels.count == 0
            ? true
            : false
            
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
        }
        
        addCurrentUserObserver()
        
        viewModel.fetchFavoritePets()
    }
    
    // MARK: - Methods and IBActions
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: FavoriteTableViewCell.identifier)
    }
    
    private func addCurrentUserObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidSet),
            name: .didSetCurrentUser, object: nil
        )
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchFavoritePets()
    }
}

// MARK: - UITableViewDataSource & Delegate
extension AdoptFavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.favoritePetViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.identifier, for: indexPath)
        
        guard
            let favoriteCell = cell as? FavoriteTableViewCell else { return cell }
        
        let selectedView = UIView()
        
        let backgroundView = UIView()
        
        selectedView.backgroundColor = UIColor.systemGray5
        
        backgroundView.backgroundColor = UIColor.systemGray6
        
        let cellViewModel = viewModel.favoritePetViewModels.value[indexPath.item]
        
        favoriteCell.configureCell(with: cellViewModel)
        
        favoriteCell.selectedBackgroundView = selectedView
        
        favoriteCell.backgroundView = backgroundView
        
        return favoriteCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptDetaiVC = storyboard.instantiateViewController(
                withIdentifier: AdoptDetailViewController.identifier)
                as? AdoptDetailViewController
                
        else { return }
        
        let selectedPetViewModel = viewModel.favoritePetViewModels.value[indexPath.item]
        
        adoptDetaiVC.viewModel = AdoptDetailViewModel(petViewModel: Box(selectedPetViewModel))
        
        adoptDetaiVC.delegate = self
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        return indexPath
    }
}

// MARK: - AdoptDetailViewControllerDelegate
extension AdoptFavoriteViewController: AdoptDetailViewControllerDelegate {
    
    func adoptDetailViewControllerFavoriteButtonDidTap() {
        
        viewModel.fetchFavoritePets()
        
        tableView.reloadData()
    }
}

// MARK: - AdoptDetailViewControllerDelegate
extension AdoptFavoriteViewController: AdoptViewControllerDelegate {
    
    func fetchFavoritePet() {
        
        viewModel.fetchFavoritePets()
    }
}
