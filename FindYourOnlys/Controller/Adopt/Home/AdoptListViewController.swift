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
    
//    private let popAnimator = PopAnimator()
//
//    private(set) var selectedCell: UICollectionViewCell!
    
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
    
//    private let favoriteButton = TransformButton()
//
//    private let currentWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    
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
            
            DispatchQueue.main.async {
                
                self?.showAlertWindow(title: "沒有更多動物資訊了喔！", message: "")
            }
            
        }
        
        viewModel.addToFavoriteHandler = { [weak self] in
            
            self?.addToFavorite()
        }
        
        viewModel.isFavoritePetViewModel.bind { [weak self] resultViewModel in
            
            guard
                let self = self else { return }
            
            var favoriteActionTitle = "加入我的最愛"
            
            if
                let isFavoritePet = resultViewModel?.result {
                
                print(isFavoritePet)
                
                favoriteActionTitle = isFavoritePet
                ? "移除我的最愛"
                : "加入我的最愛"
                
                let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
                
                let cancel = UIAlertAction(title: "取消", style: .cancel)
                
                let favoriteAction = UIAlertAction(title: favoriteActionTitle, style: .default) { _ in
                    
                    if isFavoritePet {
                        
                        if self.viewModel.didSignIn {
                            
                            self.viewModel.removeFavoriteFromFB()
                            
                        } else {
                            
                            self.viewModel.removeFavoriteFromLS()
                        }
                        
                    } else {
                        
                        if self.viewModel.didSignIn {
                            
                            self.viewModel.addToFavoriteInFB()
                            
                        } else {
                            
                            self.viewModel.addToFavoriteInLS()
                        }
                    }
                }
                
                alert.addAction(favoriteAction)
                
                alert.addAction(cancel)
                
                // iPad specific code
                alert.popoverPresentationController?.sourceView = self.view
                
                let xOrigin = self.view.bounds.width / 2
                
                let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
                
                alert.popoverPresentationController?.sourceRect = popoverRect
                
                alert.popoverPresentationController?.permittedArrowDirections = .up
                
                self.present(alert, animated: true)
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
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        collectionView.addGestureRecognizer(longPress)
        
    }
    
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        
//        let width = UIScreen.main.bounds.width
//
//        let height = UIScreen.main.bounds.height
//
//        lazy var blurView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
//
//        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
//
//        blurView.translatesAutoresizingMaskIntoConstraints = false
//
//        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
//
//        favoriteButton.frame = CGRect(x: 0, y: 0, width: width, height: height / 2)
//
//        favoriteButton.center = currentWindow!.center
        
            if sender.state == .began {
                
                let touchPoint = sender.location(in: collectionView)
                
                if
                    let indexPath = collectionView.indexPathForItem(at: touchPoint) {
                    
                    if viewModel.didSignIn {
                        
                        viewModel.fetchFavoritePet(at: indexPath.row)
                        
                    } else {
                        
                        viewModel.fetchFavoritePetFromLS(with: indexPath.row)
                    }
                    
                    
                    
//                    let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
//
//                    let cancel = UIAlertAction(title: "取消", style: .cancel)
//
//                    let favoriteAction = UIAlertAction(title: favoriteActionTitle, style: .default) { _ in
//
//
//                    }
//
//                    alert.actions.forEach { $0.title }
//
//                    alert.addAction(favoriteAction)
//
//                    alert.addAction(cancel)
//
//                    // iPad specific code
//                    alert.popoverPresentationController?.sourceView = self.view
//
//                    let xOrigin = self.view.bounds.width / 2
//
//                    let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
//
//                    alert.popoverPresentationController?.sourceRect = popoverRect
//
//                    alert.popoverPresentationController?.permittedArrowDirections = .up
//
//                    present(alert, animated: true)
                    
//                    currentWindow?.addSubview(blurView)
//
//                    currentWindow?.addSubview(favoriteButton)
                }
            }
//        else if sender.state == .ended {
//
//                favoriteButton.removeFromSuperview()
//
//                blurView.removeFromSuperview()
//            }
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
//            let selectedCell = collectionView.dequeueReusableCell(withReuseIdentifier: AdoptCollectionViewCell.identifier, for: indexPath) as? AdoptCollectionViewCell
//                ,
//            let adoptFavoriteVC = storyboard.instantiateViewController(
//                withIdentifier: AdoptFavoriteViewController.identifier)
//                as? AdoptFavoriteViewController
                
        else { return }
        
        adoptDetaiVC.viewModel.petViewModel.value = viewModel.petViewModels.value[indexPath.item]
        
        adoptDetaiVC.viewModel.petViewModel.value.pet.userID = UserFirebaseManager.shared.currentUser?.id
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
        
//        adoptDetaiVC.transitioningDelegate = self
//
//        adoptDetaiVC.modalPresentationStyle = .fullScreen
      
//        self.selectedCell = selectedCell
//
//        present(adoptDetaiVC, animated: true)

        
        
        

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

// MARK: - UIViewControllerTransitioningDelegate
//extension AdoptListViewController {
//
//    func animationController(
//      forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController
//    ) -> UIViewControllerAnimatedTransitioning? {
//
//        popAnimator.originFrame = collectionView.convert(selectedCell.frame, to: nil)
        
//        let originX = collectionView.convert(selectedCell.frame, to: nil).origin.x
//
//        let originY = collectionView.convert(selectedCell.frame, to: nil).origin.y
//
//        let height = collectionView.convert(selectedCell.frame, to: nil).height
//
//        let width = collectionView.convert(selectedCell.frame, to: nil).width
//
//        popAnimator.originFrame = CGRect(x: originX, y: originY + (selectedCell.frame.height / 2), width: width, height: height / 2)
        
//        popAnimator.presenting = true
        
//      return popAnimator
//    }
//
//    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
//        popAnimator.presenting = false
//        return popAnimator
        
//      nil
//    }
//  }

