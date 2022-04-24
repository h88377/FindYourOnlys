//
//  AdoptFavoriteViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class AdoptFavoriteViewController: BaseViewController {
    
    let viewModel = AdoptFavoriteViewModel()
    
    var didLogin: Bool = true
    
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !didLogin {
            
            viewModel.fetchFavoritePetFromLS { error in
                
                if error != nil {
                    
                    print(error)
                }
            }
            
            viewModel.favoriteLSPetViewModels.bind { [weak self] favoriteLSPetViewModels in
                
                DispatchQueue.main.async {
                    
                    self?.tableView.reloadData()
                    
                    self?.tableView.isHidden = favoriteLSPetViewModels.count == 0
                    ? true
                    : false
                }
            }
            
            
        } else {
            
            viewModel.fetchFavoritePetFromFB { error in
                
                if error != nil {
                    
                    print(error)
                }
            }
            
            viewModel.favoritePetViewModels.bind { [weak self] favoritePetViewModels in
                
                DispatchQueue.main.async {
                    
                    self?.tableView.reloadData()
                    
                    self?.tableView.isHidden = favoritePetViewModels.count == 0
                    ? true
                    : false
                }
            }
        }
        
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: FavoriteTableViewCell.identifier)
    }
    
}

// MARK: - UITableViewDataSource & Delegate
extension AdoptFavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return !didLogin
        ? viewModel.favoriteLSPetViewModels.value.count
        : viewModel.favoritePetViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.identifier, for: indexPath) as? FavoriteTableViewCell
                
        else { return UITableViewCell() }
        
        if !didLogin {
            
            let cellViewModel = viewModel.favoriteLSPetViewModels.value[indexPath.item]
            
            cell.configureCell(with: cellViewModel)
            
            return cell
            
        } else {
            
            let cellViewModel = viewModel.favoritePetViewModels.value[indexPath.item]
            
            cell.configureCell(with: cellViewModel)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptDetaiVC = storyboard.instantiateViewController(withIdentifier: AdoptDetailViewController.identifier) as? AdoptDetailViewController
                
        else { return }
        
        if !didLogin {
            
            let lsPet = viewModel.favoriteLSPetViewModels.value[indexPath.row].lsPet
            
            adoptDetaiVC.viewModel.petViewModel.value.pet = viewModel.convertLsPetToPet(from: lsPet)
            
        } else {
            
            adoptDetaiVC.viewModel.petViewModel.value = viewModel.favoritePetViewModels.value[indexPath.item]
        }
        
        adoptDetaiVC.delegate = self
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
}

// MARK: - AdoptDetailViewControllerDelegate
extension AdoptFavoriteViewController: AdoptDetailViewControllerDelegate {
    
    func toggleFavorite() {
        
        if !didLogin {
            
            viewModel.fetchFavoritePetFromLS { error in

                if error != nil {

                    print(error)
                }
            }
        } else {
            
            viewModel.fetchFavoritePetFromFB { error in

                if error != nil {

                    print(error)
                }
            }
        }
        tableView.reloadData()
    }
}

// MARK: - AdoptDetailViewControllerDelegate
extension AdoptFavoriteViewController: AdoptViewControllerDelegate {
    
    func fetchFavoritePet() {
        
        if !didLogin {
            
            viewModel.fetchFavoritePetFromLS { error in

                if error != nil {

                    print(error)
                }
            }
        } else {
            
            viewModel.fetchFavoritePetFromFB { error in

                if error != nil {

                    print(error)
                }
            }
        }
    }
}
