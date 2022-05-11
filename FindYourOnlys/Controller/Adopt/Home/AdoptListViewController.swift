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
    
    let viewModel = AdoptListViewModel()
    
    @IBOutlet weak var remindLabel: UILabel! 
    
    @IBOutlet weak var refetchButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            
            collectionView.delegate = self
            
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
    
    var resetConditionHandler: (() -> Void)?
    
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
        
        viewModel.fetchPet()
        
        startLoading()
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            if
                let error = errorViewModel?.error {
                
                DispatchQueue.main.async {
                    
                    if
                        let httpClientError = error as? HTTPClientError {
                        
                        self?.showAlertWindow(title: "異常", message: "\(httpClientError.errorMessage)")
                        
                    }
                }
            }
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
            
            DispatchQueue.main.async { [weak self] in
                
                self?.activityIndicator.start(closure: {
                    
                    self?.viewModel.fetchPet()
                })
            }
        }
        viewModel.stopIndicatorHandler = { [weak self] in
            
            DispatchQueue.main.async { [weak self] in
                
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
            
            DispatchQueue.main.async { [weak self] in
                
                self?.showAlertWindow(title: "沒有更多動物資訊了喔！", message: "")
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapButton.layer.cornerRadius = mapButton.frame.height / 2
    }
    
    override func setupCollectionView() {
        
        collectionView.registerCellWithIdentifier(identifier: AdoptCollectionViewCell.identifier)
        
        setupCollectionViewLayout()
    }
    
    private func setupCollectionViewLayout() {

        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.itemSize = CGSize(
            width: Int(164.0 / 375.0 * UIScreen.main.bounds.width),
            height: 350
        )

        flowLayout.sectionInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 24.0, right: 16.0)

        flowLayout.minimumInteritemSpacing = 0

        flowLayout.minimumLineSpacing = 24.0

        collectionView.collectionViewLayout = flowLayout
    }
    
    @IBAction func goToMap(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptPetsLocationVC = storyboard.instantiateViewController(
                withIdentifier: AdoptPetsLocationViewController.identifier)
                as? AdoptPetsLocationViewController
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        viewModel.petViewModels.value.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AdoptCollectionViewCell.identifier, for: indexPath)
                as? AdoptCollectionViewCell
                
        else { return UICollectionViewCell() }
        
        let cellViewModel = viewModel.petViewModels.value[indexPath.item]
        
        cell.configureCell(with: cellViewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptDetaiVC = storyboard.instantiateViewController(
                withIdentifier: AdoptDetailViewController.identifier)
                as? AdoptDetailViewController
//                ,
//            let adoptFavoriteVC = storyboard.instantiateViewController(
//                withIdentifier: AdoptFavoriteViewController.identifier)
//                as? AdoptFavoriteViewController
                
        else { return }
        
        adoptDetaiVC.viewModel.petViewModel.value = viewModel.petViewModels.value[indexPath.item]
        
        adoptDetaiVC.viewModel.petViewModel.value.pet.userID = UserFirebaseManager.shared.currentUser?.id
        
//        adoptDetaiVC.delegate = adoptFavoriteVC
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
    }

//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//
//        // UITableView only moves in one direction, y axis
//            let currentOffset = scrollView.contentOffset.y
//            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
//
//            // Change 10.0 to adjust the distance from bottom
//            if maximumOffset - currentOffset <= 10.0 {
////                self.loadMore()
//                print("Load more")
//            }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            activityIndicator.start {
                DispatchQueue.global(qos: .utility).async {
                    
                    self.viewModel.fetchPet()
                }
            }
        }
}

//extension AdoptListViewController: AdoptDetailViewControllerDelegate {
//
//    func toggleFavorite() {
//
//        viewModel.fetchPet()
//    }
//}
