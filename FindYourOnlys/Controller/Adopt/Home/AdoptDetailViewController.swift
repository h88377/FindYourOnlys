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

class AdoptDetailViewController: BaseViewController {
    
    var viewModel = AdoptDetailViewModel()
    
    weak var delegate: AdoptDetailViewControllerDelegate?
    
    override var isHiddenTabBar: Bool { return true }
    
    override var isHiddenNavigationBar: Bool { return true }
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var photoImageView: UIImageView! {
        
        didSet {
            
            photoImageView.tintColor = .projectPlaceHolderColor
        }
    }
    
    @IBOutlet weak var favoriteButton: UIButton! {
        
        didSet {
            
            favoriteButton.tintColor = .white
            
            favoriteButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var phoneCallButton: UIButton! {
        
        didSet {
            
            phoneCallButton.setTitleColor(.white, for: .normal)
            
            phoneCallButton.setTitleColor(.projectTextColor, for: .highlighted)
            
            phoneCallButton.backgroundColor = .projectIconColor1
            
            phoneCallButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
    }
    
    @IBOutlet weak var checkLocationButton: UIButton! {
        
        didSet {
            
            checkLocationButton.setTitleColor(.white, for: .normal)
            
            checkLocationButton.setTitleColor(.projectTextColor, for: .highlighted)
            
            checkLocationButton.backgroundColor = .projectIconColor1
            
            checkLocationButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        
        didSet {
            
            backButton.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var bottomBaseView: UIView! {
        
        didSet {
            
            bottomBaseView.backgroundColor = .projectBackgroundColor2
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.petViewModel.bind { [weak self] petViewModels in
            
            DispatchQueue.main.async {
                
                self?.tableView.reloadData()
            }
        }
        
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
        
        viewModel.checkFavoriateButtonHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.viewModel.checkFavoriteButton(with: self.favoriteButton)
        }
        
        //Create a function to replace
        if !viewModel.didSignIn {
            
            viewModel.fetchFavoritePetFromLS()
            
//            self.viewModel.checkFavoriteButton(with: self.favoriteButton)
            
        } else {
            
            viewModel.fetchFavoriteFromFB()
            
//                    self.viewModel.checkFavoriteButton(with: self.favoriteButton)
        }
        
        photoImageView.loadImage(
            viewModel.petViewModel.value.pet.photoURLString,
            placeHolder: UIImage.asset(.findYourOnlysPlaceHolder)
        )
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        baseView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        
        bottomBaseView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        
        phoneCallButton.layer.cornerRadius = 15
        
        checkLocationButton.layer.cornerRadius = 15
        
        favoriteButton.layer.cornerRadius = 15
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailTableViewCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailDecriptionTableViewCell.identifier)
    }
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        
        if !viewModel.didSignIn {
            
            // Local Storage
            viewModel.fetchFavoritePetFromLS()
            
        } else {
            
            // Firebase
            viewModel.fetchFavoriteFromFB()
        }
        
        viewModel.toggleFavoriteButton(with: sender)
        
        self.delegate?.toggleFavorite()
    }
    
    @IBAction func makePhoneCall(_ sender: UIButton) {
        
        viewModel.makePhoneCall(self)
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkLocation(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let petsLocationVC = storyboard.instantiateViewController(
                withIdentifier: AdoptPetsLocationViewController.identifier)
                as? AdoptPetsLocationViewController
        
        else { return }
        
        petsLocationVC.viewModel.petViewModel = viewModel.petViewModel
        
        petsLocationVC.viewModel.isShelterMap = false
        
        navigationController?.pushViewController(petsLocationVC, animated: true)
    }
    
}

// MARK: - UITableViewDelegate & DataSource
extension AdoptDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let adoptDetailDescription = viewModel.adoptDetailContentCategory
        
        return 1 + adoptDetailDescription.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellViewModel = viewModel.petViewModel.value
        
        let adoptDetailContentCategory = viewModel.adoptDetailContentCategory
        
        if indexPath.item == 0 {
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: AdoptDetailTableViewCell.identifier, for: indexPath) as? AdoptDetailTableViewCell
                    
            else { return UITableViewCell() }
            
            cell.configureCell(with: cellViewModel)
            
            return cell
            
        } else {
            
            return adoptDetailContentCategory[indexPath.item - 1].cellForIndexPath(indexPath, tableView: tableView, viewModel: cellViewModel)
//            return adoptDetailDescription[indexPath.item - 1].cellForIndexPath(indexPath, tableView: tableView, pet: cellViewModel.pet)
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        if indexPath.row == 0 {
//
//            return tableView.estimatedRowHeight
//
//        } else {
//
//            return tableView.estimatedRowHeight
//        }
//    }
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
