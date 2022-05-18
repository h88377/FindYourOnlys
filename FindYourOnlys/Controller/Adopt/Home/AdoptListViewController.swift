//
//  AdoptListViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit
import Lottie

class AdoptListViewController: BaseViewController {
    
    // MARK: - Properties
    
    let viewModel = AdoptListViewModel()

    @IBOutlet private weak var reminderLabel: UILabel!
    
    @IBOutlet private weak var refetchButton: UIButton!
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            
            collectionView.delegate = self
            
            collectionView.allowsSelection = true
            
            collectionView.backgroundColor = .projectBackgroundColor
        }
    }
    
    @IBOutlet private weak var mapButton: UIButton! {
        
        didSet {
            
            mapButton.backgroundColor = .projectIconColor2
            
            mapButton.tintColor = .white
        }
    }
            
    private var activityIndicator: LoadMoreActivityIndicator!
    
    var resetConditionHandler: (() -> Void)?
    
    // MARK: - View Life Cycle
    
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
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                self.showAlertWindow(of: error)
            }
        }
        
        viewModel.isSelectedPetFavorite.bind { [weak self] isFavorite in
            
            guard
                let self = self else { return }
            
            self.showFavoriteAlert(with: isFavorite)
        }
        
        viewModel.resetPetHandler = { [weak self] in
            
            guard
                let self = self,
                self.viewModel.petViewModels.value.count > 0
            
            else { return }
            
            DispatchQueue.main.async {
                
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        }
        
        viewModel.noMorePetHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.showAlertWindow(title: "沒有更多動物資訊了喔！")
        }
        
        viewModel.addToFavoriteHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.addToFavorite()
        }
        
        activityIndicator = LoadMoreActivityIndicator(
            scrollView: collectionView,
            spacingFromLastCell: 10,
            spacingFromLastCellWhenLoadMoreActionStart: 60
        )
        
        setupLoadingViewHandler()
        
        setupIndicatorViewHandler()
        
        startLoading()
        
        viewModel.fetchPet()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapButton.makeRound()
    }
    
    // MARK: - Method and IBAction
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
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
    
    private func setupLoadingViewHandler() {
        
        viewModel.startLoadingHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.stopLoading()
        }
    }
    
    private func setupIndicatorViewHandler() {
        
        viewModel.startIndicatorHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.activityIndicator.start {
                    
                    self.viewModel.fetchPet()
                }
            }
        }
        
        viewModel.stopIndicatorHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.activityIndicator.stop()
            }
        }
    }
    
    private func showFavoriteAlert(with isFavorite: Bool) {
        
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
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            
            let touchPoint = sender.location(in: collectionView)
            
            if
                let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                
                viewModel.fetchFavoritePet(at: indexPath.row)
            }
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
    
    @IBAction func refetchPetInfo(_ sender: UIButton) {
        
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
        
        selectedPetViewModel.pet.userID = currentUserId
        
//        adoptDetaiVC.viewModel.petViewModel.value = selectedPetViewModel
        
        adoptDetaiVC.viewModel = AdoptDetailViewModel(petViewModel: Box(selectedPetViewModel))
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        activityIndicator.start { [weak self] in
            
            guard
                let self = self else { return }
            
            DispatchQueue.global(qos: .utility).async {
                
                self.viewModel.fetchPet()
            }
        }
    }
}
