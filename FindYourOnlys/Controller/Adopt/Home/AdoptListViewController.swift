//
//  AdoptListViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit

class AdoptListViewController: BaseViewController {
    
    let viewModel = AdoptListViewModel()
    
    var isLogin = false
    
    @IBOutlet weak var remindLabel: UILabel! {
        
        didSet {
            
//            remindLabel.alpha = 0
        }
    }
    
    @IBOutlet weak var refetchButton: UIButton! {
        
        didSet {
            
//            refetchButton.alpha = 0
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            
            collectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.petViewModels.bind { [weak self] petViewModels in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.collectionView.reloadData()
                
                self.collectionView.isHidden = petViewModels.count == 0
                ? true
                : false
                
//                self.remindLabel.alpha =
//                self.collectionView.isHidden
//                ? 1
//                : 0
//
//                self.refetchButton.alpha =
//                self.collectionView.isHidden
//                ? 1
//                : 0
            }
        }
        
        viewModel.fetchPet()
        
        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                let errorViewModel = errorViewModel else { return }
            
            print(errorViewModel.error)
        }
        
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
            let adoptPetsLocationVC = storyboard.instantiateViewController(withIdentifier: AdoptPetsLocationViewController.identifier) as? AdoptPetsLocationViewController
        
        else { return }
        
        adoptPetsLocationVC.viewModel.isShelterMap = true
        
        navigationController?.pushViewController(adoptPetsLocationVC, animated: true)
    }
    
    @IBAction func goToFilter(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptFilterLocationVC = storyboard.instantiateViewController(withIdentifier: AdoptFilterViewController.identifier) as? AdoptFilterViewController
        
        else { return }
        
        navigationController?.pushViewController(adoptFilterLocationVC, animated: true)
    }
    
    @IBAction func reFetchPetInfo(_ sender: UIButton) {
        
        viewModel.fetchPet()
    }
    
}

// MARK: - UICollectionViewDataSource & Delegate
extension AdoptListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        viewModel.petViewModels.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AdoptCollectionViewCell.identifier, for: indexPath) as? AdoptCollectionViewCell
                
        else { return UICollectionViewCell() }
        
        let cellViewModel = viewModel.petViewModels.value[indexPath.item]
        
        cell.configureCell(with: cellViewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.adopt
        
        guard
            let adoptDetaiVC = storyboard.instantiateViewController(withIdentifier: AdoptDetailViewController.identifier) as? AdoptDetailViewController,
            let adoptFavoriteVC = storyboard.instantiateViewController(withIdentifier: AdoptFavoriteViewController.identifier) as? AdoptFavoriteViewController
                
        else { return }
        
        adoptDetaiVC.viewModel.petViewModel.value = viewModel.petViewModels.value[indexPath.item]
        
        adoptDetaiVC.viewModel.petViewModel.value.pet.userID = UserFirebaseManager.shared.currentUser
        
//        adoptDetaiVC.delegate = adoptFavoriteVC
        
        navigationController?.pushViewController(adoptDetaiVC, animated: true)
    }

}

//extension AdoptListViewController: AdoptDetailViewControllerDelegate {
//
//    func toggleFavorite() {
//
//        viewModel.fetchPet()
//    }
//}
