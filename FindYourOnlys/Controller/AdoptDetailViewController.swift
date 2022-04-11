//
//  AdoptDetailViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

protocol AdoptDetailViewControllerDelegate: AnyObject {
    
    func toggleFavorite()
}

class AdoptDetailViewController: UIViewController {
    
    var viewModel = AdoptDetailViewModel()
    
    weak var delegate: AdoptDetailViewControllerDelegate?
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        viewModel.petViewModel.bind { [weak self] petViewModels in
            
            DispatchQueue.main.async {
                
                self?.tableView.reloadData()
            }
        }
        viewModel.fetchFavoritePetFromLS { error in
            
            if error != nil {
                
                print(error)
            }
            
        }
        
        viewModel.checkFavoriteButton(with: favoriteButton)
        
        photoImageView.loadImage(viewModel.petViewModel.value.pet.photoURLString)
    }
 
    @IBAction func toggleFavorite(_ sender: UIButton) {
        
        viewModel.fetchFavoritePetFromLS { error in

            if error != nil {

                print(error)
            }
        }
        
        viewModel.toggleFavoriteButton(with: sender)
        
        self.delegate?.toggleFavorite()
    }
    
    func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailTableViewCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailDecriptionTableViewCell.identifier)
    }

}

// MARK: - UITableViewDelegate & DataSource
extension AdoptDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let adoptDetailDescription = viewModel.adoptDetailDescription
        
        return 1 + adoptDetailDescription.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellViewModel = viewModel.petViewModel.value
        
        let adoptDetailDescription = viewModel.adoptDetailDescription
        
        if indexPath.item == 0 {
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: AdoptDetailTableViewCell.identifier, for: indexPath) as? AdoptDetailTableViewCell
                    
            else { return UITableViewCell() }
            
            cell.configureCell(with: cellViewModel)
            
            return cell
            
        } else {
            
            return adoptDetailDescription[indexPath.item - 1].cellForIndexPath(indexPath, tableView: tableView, viewModel: cellViewModel)
//            return adoptDetailDescription[indexPath.item - 1].cellForIndexPath(indexPath, tableView: tableView, pet: cellViewModel.pet)
        }
    }
}


//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
    
//        tableView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
//    }

//        viewModel.favoritePetViewModels.bind { [weak self] favoritePetViewModels in
            
//            self?.viewModel.isFavorite(with: &self!.favoriteButton)
//            self?.favoriteButton.setTitle("AddToFavorite", for: .normal)
//
//            for favoritePetViewModel in favoritePetViewModels {
//
//                if favoritePetViewModel.pet.id == self?.viewModel.petViewModel.value.pet.id {
//
//                    self?.favoriteButton.setTitle("RemoveFromFavorite", for: .normal)
//
//                    break
//                }
//
//
//            }
//        }
