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
    
    @IBOutlet weak var bottomBaseView: UIView! {
        
        didSet {
            
            bottomBaseView.backgroundColor = .projectBackgroundColor2
        }
    }
    
    let tableView = UITableView()
    
    let backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.petViewModel.bind { [weak self] _ in
            
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
        
        // Create a function to replace
        if !viewModel.didSignIn {
            
            viewModel.fetchFavoritePetFromLS()
            
            //            self.viewModel.checkFavoriteButton(with: self.favoriteButton)
            
        } else {
            
            viewModel.fetchFavoriteFromFB()
            
            //                    self.viewModel.checkFavoriteButton(with: self.favoriteButton)
        }
        
        viewModel.shareHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            // Generate the screenshot
            UIGraphicsBeginImageContext(self.view.frame.size)
            
            self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            let items: [Any] = [image]
            
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            // iPad specific code
            activityVC.popoverPresentationController?.sourceView = self.view
            
            let xOrigin = self.view.bounds.width / 2
            
            let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
            
            activityVC.popoverPresentationController?.sourceRect = popoverRect
            
            activityVC.popoverPresentationController?.permittedArrowDirections = .up
            
            self.present(activityVC, animated: true)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomBaseView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        
        phoneCallButton.layer.cornerRadius = 15
        
        checkLocationButton.layer.cornerRadius = 15
        
        favoriteButton.layer.cornerRadius = 15
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailTableViewCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: AdoptDetailDecriptionTableViewCell.identifier)
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        view.insertSubview(tableView, belowSubview: bottomBaseView)
        
        tableView.separatorStyle = .none
        
        tableView.allowsSelection = false
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                tableView.topAnchor.constraint(equalTo: view.topAnchor),
                
                tableView.bottomAnchor.constraint(equalTo: bottomBaseView.topAnchor, constant: 5)
            ]
        )
        
        let header = AdoptDetailHeaderView(frame: CGRect(
            x: 0, y: 0,
            width: view.frame.width,
            height: view.frame.width)
        )
        
        header.configureView(with: viewModel.petViewModel.value)
        
        tableView.tableHeaderView = header
        
        setupButton()
    }
    
    func setupButton() {
        
        view.addSubview(backButton)
        
        backButton.frame = CGRect(
            x: 0, y: 0,
            width: 40,
            height: 40
        )
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                
                backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
                
                backButton.heightAnchor.constraint(equalToConstant: 40),
                
                backButton.widthAnchor.constraint(equalToConstant: 40)
            ]
        )
        
        let config = UIImage.SymbolConfiguration(pointSize: 34)
        
        let image = UIImage(systemName: SystemImageAsset.back.rawValue, withConfiguration: config)
        
        backButton.setImage(image, for: .normal)
        
        backButton.tintColor = .projectIconColor1
        
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
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
    
    @objc func back(_ sender: UIButton) {
        
//        navigationController?.popViewController(animated: true)
        
        dismiss(animated: true)
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
extension AdoptDetailViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
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
            
            cell.shareHandler = { [weak self] in
                
                self?.viewModel.share()
            }
            
            return cell
            
        } else {
            
            return adoptDetailContentCategory[indexPath.item - 1].cellForIndexPath(indexPath, tableView: tableView, viewModel: cellViewModel)
        }
    }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            guard
                let header = tableView.tableHeaderView as? AdoptDetailHeaderView else { return }
            
            header.scrollViewDidScroll(scrollView: tableView)
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

