//
//  AdoptFavoriteViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import UIKit

class AdoptFavoriteViewController: BaseViewController {
    
    let viewModel = AdoptFavoriteViewModel()
    
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.backgroundColor = .projectBackgroundColor
            
            tableView.allowsSelection = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCurrentUserObserver()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            if
                let error = errorViewModel?.error {
                
                DispatchQueue.main.async {
                    
                    if
                        let firebaseError = error as? FirebaseError {
                        
                        self?.showAlertWindow(title: "異常", message: "\(firebaseError.errorMessage)")
                        
                    } else if
                        let localStorageError = error as? LocalStorageError {
                        
                        self?.showAlertWindow(title: "異常", message: "\(localStorageError.errorMessage)")
                    }
                }
            }
            
        }
        
        fetchPet()
        
//        viewModel.favoriteLSPetViewModels.bind { [weak self] favoriteLSPetViewModels in
//
//            DispatchQueue.main.async {
//
//                self?.tableView.reloadData()
//
//                self?.tableView.isHidden = favoriteLSPetViewModels.count == 0
//                ? true
//                : false
//            }
//        }
//
//        viewModel.favoritePetViewModels.bind { [weak self] favoritePetViewModels in
//
//            DispatchQueue.main.async {
//
//                self?.tableView.reloadData()
//
//                self?.tableView.isHidden = favoritePetViewModels.count == 0
//                ? true
//                : false
//            }
//        }
//
//        if !viewModel.didSignIn {
//
//            viewModel.fetchFavoritePetFromLS()
//
//        } else {
//
//            viewModel.fetchFavoritePetFromFB()
//        }
    }
    
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
    
    private func fetchPet() {
        
        if !viewModel.didSignIn {

            viewModel.fetchFavoritePetFromLS()

            viewModel.favoriteLSPetViewModels.bind { [weak self] favoriteLSPetViewModels in

                DispatchQueue.main.async {

                    self?.tableView.reloadData()

                    self?.tableView.isHidden = favoriteLSPetViewModels.count == 0
                    ? true
                    : false
                }
            }

        } else {

            viewModel.fetchFavoritePetFromFB()

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
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        fetchPet()
    }
    
}

// MARK: - UITableViewDataSource & Delegate
extension AdoptFavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return !viewModel.didSignIn
        ? viewModel.favoriteLSPetViewModels.value.count
        : viewModel.favoritePetViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteTableViewCell.identifier, for: indexPath) as? FavoriteTableViewCell
                
        else { return UITableViewCell() }
        
        let selectedView = UIView()
        
        let backgroundView = UIView()

        selectedView.backgroundColor = UIColor.systemGray5
        
        backgroundView.backgroundColor = UIColor.systemGray6
        
        if !viewModel.didSignIn {
            
            let cellViewModel = viewModel.favoriteLSPetViewModels.value[indexPath.item]
            
            cell.configureCell(with: cellViewModel)
            
            cell.selectedBackgroundView = selectedView
            
            cell.backgroundView = backgroundView
            
            return cell
            
        } else {
            
            let cellViewModel = viewModel.favoritePetViewModels.value[indexPath.item]
            
            cell.configureCell(with: cellViewModel)
            
            cell.selectedBackgroundView = selectedView
            
            cell.backgroundView = backgroundView
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptDetaiVC = storyboard.instantiateViewController(
                withIdentifier: AdoptDetailViewController.identifier)
                as? AdoptDetailViewController
                
        else { return }
        
        if !viewModel.didSignIn {
            
            let lsPet = viewModel.favoriteLSPetViewModels.value[indexPath.row].lsPet
            
            adoptDetaiVC.viewModel.petViewModel.value.pet = viewModel.convertLsPetToPet(from: lsPet)
            
        } else {
            
            adoptDetaiVC.viewModel.petViewModel.value = viewModel.favoritePetViewModels.value[indexPath.item]
        }
        
        adoptDetaiVC.delegate = self
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        250
//    }
    
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
    
    func toggleFavorite() {
        
        if !viewModel.didSignIn {
            
            viewModel.fetchFavoritePetFromLS()
            
        } else {
            
            viewModel.fetchFavoritePetFromFB()
        }
        tableView.reloadData()
    }
}

// MARK: - AdoptDetailViewControllerDelegate
extension AdoptFavoriteViewController: AdoptViewControllerDelegate {
    
    func fetchFavoritePet() {
        
        if !viewModel.didSignIn {
            
            viewModel.fetchFavoritePetFromLS()
        } else {
            
            viewModel.fetchFavoritePetFromFB()
        }
    }
}
