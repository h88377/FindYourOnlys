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
        
        viewModel.fetchFavoritePet { error in
            
            if error != nil {
                
                print(error)
            }
        }
        
        viewModel.petViewModels.bind { [weak self] petViewModels in
            
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
        
        viewModel.petViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.identifier, for: indexPath) as? FavoriteTableViewCell
                
        else { return UITableViewCell() }
        
        let cellViewModel = viewModel.petViewModels.value[indexPath.item]
        
        cell.configureCell(with: cellViewModel)
        
        return cell
    }
    
}

