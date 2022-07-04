//
//  AdoptDetailViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/10.
//

import UIKit

protocol AdoptDetailViewControllerDelegate: AnyObject {
    
    func adoptDetailViewControllerFavoriteButtonDidTap()
}

class AdoptDetailViewController: BaseViewController {
    
    // MARK: - Properties
    
    var viewModel: AdoptDetailViewModel?
    
    weak var delegate: AdoptDetailViewControllerDelegate?
    
    @IBOutlet private weak var favoriteButton: UIButton! {
        
        didSet {
            
            favoriteButton.tintColor = .white
            
            favoriteButton.adjustsImageWhenHighlighted = false
            
            favoriteButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var phoneCallButton: UIButton! {
        
        didSet {
            
            phoneCallButton.setTitleColor(.white, for: .normal)
            
            phoneCallButton.setTitleColor(.projectTextColor, for: .highlighted)
            
            phoneCallButton.backgroundColor = .projectIconColor1
            
            phoneCallButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
    }
    
    @IBOutlet private weak var checkLocationButton: UIButton! {
        
        didSet {
            
            checkLocationButton.setTitleColor(.white, for: .normal)
            
            checkLocationButton.setTitleColor(.projectTextColor, for: .highlighted)
            
            checkLocationButton.backgroundColor = .projectIconColor1
            
            checkLocationButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        }
    }
    
    @IBOutlet private weak var bottomBaseView: UIView! {
        
        didSet {
            
            bottomBaseView.backgroundColor = .projectBackgroundColor2
        }
    }
    
    private let tableView = UITableView()
    
    private let backButton = UIButton()
    
    override var isHiddenTabBar: Bool { return true }
    
    override var isHiddenNavigationBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel?.petViewModel.bind { [weak self] _ in
            
            guard
                let self = self else { return }
            
            self.tableView.reloadData()
        }
        
        viewModel?.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
        }
        
        viewModel?.shareHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            AlertWindowManager.shared.showShareActivity(at: self)
        }
        
        viewModel?.makePhoneCallHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            guard
                let phoneNumber = self.viewModel?.petViewModel.value.pet.telephone,
                let url = URL(string: "tel://\(String(describing: phoneNumber))"),
                UIApplication.shared.canOpenURL(url)
                    
            else {
                
                AlertWindowManager.shared.showAlertWindow(at: self, title: "號碼錯誤", message: "電話號碼格式錯誤，麻煩使用手機撥號")
                
                return
            }
            
            if #available(iOS 10, *) {
                
                UIApplication.shared.open(url)
                
            } else {
                
                UIApplication.shared.openURL(url)
            }
        }
        
        configureFavoriteButton()
        
        viewModel?.fetchFavoritePet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        bottomBaseView.roundCorners(corners: [.topLeft, .topRight], radius: 15)
        
        phoneCallButton.layer.cornerRadius = 15
        
        checkLocationButton.layer.cornerRadius = 15
        
        favoriteButton.layer.cornerRadius = 15
    }
    
    // MARK: - Methods and IBActions
    
    override func setupTableView() {
        
        guard
            let viewModel = viewModel else { return }
        
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
    
    private func setupButton() {
        
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
    
    private func configureFavoriteButton() {
        
        viewModel?.checkFavoriateButtonHandler = { [weak self] in
            
            guard
                let self = self,
                let favoritePetViewModels = self.viewModel?.favoritePetViewModels.value,
                let pet = self.viewModel?.petViewModel.value.pet
            
            else { return }
            
            self.favoriteButton.setImage(UIImage.system(.addToFavorite), for: .normal)
            
            for favoritePetViewModel in favoritePetViewModels where favoritePetViewModel.pet.id == pet.id {
                
                self.favoriteButton.setImage(UIImage.system(.removeFromFavorite), for: .normal)
            }
        }
        
        viewModel?.toggleFavoriteButtonHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            if self.favoriteButton.currentImage == UIImage.system(.addToFavorite) {
                
                self.viewModel?.addPetInFavorite()
                
            } else {
                
                self.viewModel?.removeFavoritePet()
            }
            
            self.favoriteButton.setImage(
                self.favoriteButton.currentImage == UIImage.system(.addToFavorite)
                ? UIImage.system(.removeFromFavorite)
                : UIImage.system(.addToFavorite), for: .normal
            )
        }
    }
    
    @IBAction func pressFavoriteButton(_ sender: UIButton) {
        
        viewModel?.fetchFavoritePet()
        
        viewModel?.toggleFavoriteButton()
        
        self.delegate?.adoptDetailViewControllerFavoriteButtonDidTap()
    }
    
    @IBAction func makePhoneCall(_ sender: UIButton) {
        
        viewModel?.makePhoneCall()
    }
    
    @objc func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func checkLocation(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let petsLocationVC = storyboard.instantiateViewController(
                withIdentifier: AdoptPetsLocationViewController.identifier
            ) as? AdoptPetsLocationViewController,
            let viewModel = viewModel
                
        else { return }
        
        petsLocationVC.viewModel.pet = viewModel.petViewModel.value.pet
        
        petsLocationVC.viewModel.isShelterMap = false
        
        navigationController?.pushViewController(petsLocationVC, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension AdoptDetailViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard
            let adoptDetailDescription = viewModel?.adoptDetailContentCategory else { return 0 }
        
        return 1 + adoptDetailDescription.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cellViewModel = viewModel?.petViewModel.value,
            let adoptDetailContentCategory = viewModel?.adoptDetailContentCategory
        
        else { return UITableViewCell() }
        
        if indexPath.item == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AdoptDetailTableViewCell.identifier,
                for: indexPath
            )
            
            guard
                let detailCell = cell as? AdoptDetailTableViewCell
                    
            else { return cell }
            
            detailCell.configureCell(with: cellViewModel)
            
            detailCell.shareHandler = { [weak self] in
                
                guard
                    let self = self else { return }
                
                self.viewModel?.share()
            }
            
            return detailCell
            
        } else {
            
            let detailContentCell = adoptDetailContentCategory[indexPath.item - 1].cellForIndexPath(
                indexPath,
                tableView: tableView,
                viewModel: cellViewModel
            )
            
            return detailContentCell
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard
            let header = tableView.tableHeaderView as? AdoptDetailHeaderView else { return }
        
        header.scrollViewDidScroll(scrollView: tableView)
    }
}
