//
//  AdoptFavoriteViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class AdoptFavoriteViewController: UIViewController {
    
    let viewModel = AdoptFavoriteViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        viewModel.fetchFavoritePetFromLS { error in
            
            if error != nil {
                
                print(error)
            }
        }
        
        viewModel.favoritePetViewModels.bind { [weak self] favoritePetViewModels in
            
            DispatchQueue.main.async {
                
                self?.tableView.reloadData()
            }
        }
    }
    
    func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: FavoriteTableViewCell.identifier)
        
    }
    
}

// MARK: - UITableViewDataSource & Delegate
extension AdoptFavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.favoritePetViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.identifier, for: indexPath) as? FavoriteTableViewCell
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.favoritePetViewModels.value[indexPath.item]
        
        cell.configureCell(with: cellViewModel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let adoptDetaiVC = storyboard?.instantiateViewController(withIdentifier: AdoptDetailViewController.identifier) as? AdoptDetailViewController
                
        else { return }
        
//        adoptDetaiVC.viewModel.petViewModel.value = viewModel.favoritePetViewModels.value[indexPath.item]
        
        let lsPet = viewModel.favoritePetViewModels.value[indexPath.row].lsPet
        
        adoptDetaiVC.viewModel.petViewModel.value.pet = viewModel.convertLsPetToPet(from: lsPet)
        
        adoptDetaiVC.delegate = self
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
    }
}

// MARK: - AdoptDetailViewControllerDelegate
extension AdoptFavoriteViewController: AdoptDetailViewControllerDelegate {
    
    func toggleFavorite() {
        
        viewModel.fetchFavoritePetFromLS { error in

            if error != nil {

                print(error)
            }
        }
    }
    
}

// MARK: - AdoptDetailViewControllerDelegate
extension AdoptFavoriteViewController: AdoptViewControllerDelegate {
    
    func fetchFavoritePet() {
        
        viewModel.fetchFavoritePetFromLS { error in
            
            if error != nil {
                
                print(error)
            }
        }
    }
}
