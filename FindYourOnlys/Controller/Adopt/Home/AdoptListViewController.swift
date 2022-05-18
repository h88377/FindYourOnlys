//
//  AdoptListViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit
import Lottie

// 1. viewModel內宣告的變數是否都要包一層viewModel?

class AdoptListViewController: BaseViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var remindLabel: UILabel!
    
    @IBOutlet weak var refetchButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            
            collectionView.delegate = self
            
            collectionView.allowsSelection = true
            
            collectionView.backgroundColor = .projectBackgroundColor
        }
    }
    
    @IBOutlet weak var mapButton: UIButton! {
        
        didSet {
            
            mapButton.backgroundColor = .projectIconColor2
            
            mapButton.tintColor = .white
        }
    }
    
    private var activityIndicator: LoadMoreActivityIndicator!
    
    let viewModel = AdoptListViewModel()
    
    var resetConditionHandler: (() -> Void)?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.petViewModels.bind { [weak self] petViewModels in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
                
                self.collectionView.isHidden = petViewModels.count == 0
            }
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            if
                let error = errorViewModel?.error {
                
                if
                    let httpClientError = error as? HTTPClientError {
                    
                    self?.showAlertWindow(title: "異常", message: "\(httpClientError.errorMessage)")
                }
            }
        }
        
        viewModel.selectedPetIsFavorite.bind { [weak self] isFavorite in
            
            self?.showFavoriteAlert(with: isFavorite)
        }
        
        activityIndicator = LoadMoreActivityIndicator(
            scrollView: collectionView,
            spacingFromLastCell: 10,
            spacingFromLastCellWhenLoadMoreActionStart: 60
        )
        
        viewModel.startLoadingHandler = { [weak self] in
            
            self?.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            self?.stopLoading()
        }
        
        viewModel.startIndicatorHandler = { [weak self] in
            
            DispatchQueue.main.async {
                
                self?.activityIndicator.start(closure: {
                    
                    self?.viewModel.fetchPet()
                })
            }
        }
        viewModel.stopIndicatorHandler = { [weak self] in
            
            DispatchQueue.main.async {
                
                self?.activityIndicator.stop()
            }
        }
        
        viewModel.resetPetHandler = { [weak self] in
            
            guard
                let self = self,
                self.viewModel.petViewModels.value.count > 0 else { return }
            
            DispatchQueue.main.async {
                
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        }
        
        viewModel.noMorePetHandler = { [weak self] in
            
            self?.showAlertWindow(title: "沒有更多動物資訊了喔！", message: "")
        }
        
        viewModel.addToFavoriteHandler = { [weak self] in
            
            self?.addToFavorite()
        }
        
        viewModel.fetchPet()
        
        startLoading()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapButton.layer.cornerRadius = mapButton.frame.height / 2
    }
    
    // MARK: - Method and IBAction
    
    override func setupCollectionView() {
        
        collectionView.registerCellWithIdentifier(identifier: AdoptCollectionViewCell.identifier)
        
        setupCollectionViewLayout()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        collectionView.addGestureRecognizer(longPress)
        
    }
    
    private func setupCollectionViewLayout() {
        
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(
            width: Int(164.0 / 375.0 * UIScreen.main.bounds.width),
            height: 290
        )
        
        flowLayout.sectionInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 24.0, right: 16.0)
        
        flowLayout.minimumInteritemSpacing = 0
        
        flowLayout.minimumLineSpacing = 24.0
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            let touchPoint = sender.location(in: collectionView)
            
            if
                let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                
                viewModel.fetchFavoritePet(at: indexPath.row)
            }
        }
    }
    
    private func showFavoriteAlert(with isFavorite: Bool?) {
        
        if
            let isFavorite = isFavorite {
            
            let favoriteActionTitle = isFavorite
            ? "移除我的最愛"
            : "加入我的最愛"
            
            let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
            
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            
            let favoriteAction = UIAlertAction(title: favoriteActionTitle, style: .default) { _ in
                
                self.viewModel.toggleFavoritePet()
            }
            
            alert.addAction(favoriteAction)
            
            alert.addAction(cancel)
            
            // iPad specific code
            self.configureIpadAlert(with: alert)
            
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func goToMap(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptPetsLocationVC = storyboard.instantiateViewController(
                withIdentifier: AdoptPetsLocationViewController.identifier
            ) as? AdoptPetsLocationViewController
                
        else { return }
        
        adoptPetsLocationVC.viewModel.isShelterMap = true
        
        navigationController?.pushViewController(adoptPetsLocationVC, animated: true)
    }
    
    @IBAction func reFetchPetInfo(_ sender: UIButton) {
        
        viewModel.resetFilterCondition()
        
        viewModel.resetFetchPet()
        
        resetConditionHandler?()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension AdoptListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        viewModel.petViewModels.value.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AdoptCollectionViewCell.identifier, for: indexPath)
        
        guard
            let adoptCell = cell as? AdoptCollectionViewCell
                
        else { return cell }
        
        let cellViewModel = viewModel.petViewModels.value[indexPath.item]
        
        adoptCell.configureCell(with: cellViewModel)
        
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptDetaiVC = storyboard.instantiateViewController(
                withIdentifier: AdoptDetailViewController.identifier)
                as? AdoptDetailViewController
                
        else { return }
        
        let selectedPetViewModel = viewModel.petViewModels.value[indexPath.item]
        
        let currentUserId = UserFirebaseManager.shared.currentUser?.id
        
        adoptDetaiVC.viewModel.petViewModel.value = selectedPetViewModel
        
        adoptDetaiVC.viewModel.petViewModel.value.pet.userID = currentUserId
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        activityIndicator.start {
            
            DispatchQueue.global(qos: .utility).async {
                
                self.viewModel.fetchPet()
            }
        }
    }
}

//        viewModel.isFavoritePetViewModel.bind { [weak self] isFavoritePet in
//
//            guard
//                let self = self else { return }
//
//            if
//                let isFavoritePet = resultViewModel?.result {
//
//                let favoriteActionTitle = isFavoritePet
//                ? "移除我的最愛"
//                : "加入我的最愛"
//
//                let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
//
//                let cancel = UIAlertAction(title: "取消", style: .cancel)
//
//                let favoriteAction = UIAlertAction(title: favoriteActionTitle, style: .default) { _ in
//
//                    self.viewModel.toggleFavoritePet()
//                }
//
//                alert.addAction(favoriteAction)
//
//                alert.addAction(cancel)
//
//                // iPad specific code
//                self.configureIpadAlert(with: alert)
//
//                self.present(alert, animated: true)
//            }
//        }
