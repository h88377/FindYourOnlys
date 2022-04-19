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
    
    var didLogin: Bool = true
    
    override var isHiddenTabBar: Bool { return true }
    
    override var isHiddenNavigationBar: Bool { return true }
    
    @IBOutlet weak var baseView: UIView!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton! {
        
        didSet {
            
            favoriteButton.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var phoneCallButton: UIButton! {
        
        didSet {
            
            phoneCallButton.setTitleColor(.gray, for: .highlighted)
            
            phoneCallButton.setTitleColor(.black, for: .normal)
        }
    }
    
    @IBOutlet weak var checkLocationButton: UIButton! {
        
        didSet {
            
            checkLocationButton.setTitleColor(.gray, for: .highlighted)
            
            checkLocationButton.setTitleColor(.black, for: .normal)
        }
    }
    
    @IBOutlet weak var backButton: UIButton! {
        
        didSet {
            
            backButton.tintColor = .systemGray2
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
        
        //Create a function to replace
        if !didLogin {
            
            viewModel.fetchFavoritePetFromLS { error in
                
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    self.viewModel.checkFavoriteButton(with: self.favoriteButton)
                }
                
            }
            
        } else {
            
            viewModel.fetchFavoriteFromFB { error in
                
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    self.viewModel.checkFavoriteButton(with: self.favoriteButton)
                }
            }
        }
        photoImageView.loadImage(viewModel.petViewModel.value.pet.photoURLString)
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        baseView.roundCorners(corners: [.topLeft, .topRight], radius: 12)
    }
    
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailTableViewCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailDecriptionTableViewCell.identifier)
    }
    
    @IBAction func toggleFavorite(_ sender: UIButton) {
        
        if !didLogin {
            
            // Local Storage
            viewModel.fetchFavoritePetFromLS { error in
                
                if error != nil {
                    
                    print(error)
                }
            }
            
        } else {
            
            // Firebase
            viewModel.fetchFavoriteFromFB { error in
                
                if error != nil {
                    
                    print(error)
                }
            }
        }
        
        viewModel.toggleFavoriteButton(with: sender) { error in
            
            if error != nil {

                print(error)
            }
        }
        
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
            let petLocationVC = storyboard.instantiateViewController(withIdentifier: PetLocationViewController.identifier) as? PetLocationViewController
        
        else { return }
        
        petLocationVC.viewModel.petViewModel = viewModel.petViewModel
        
        navigationController?.pushViewController(petLocationVC, animated: true)
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            
            return 170
            
        } else {
            
            return tableView.estimatedRowHeight
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
