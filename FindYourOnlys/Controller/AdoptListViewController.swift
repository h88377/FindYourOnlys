//
//  AdoptListViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/9.
//

import Foundation
import UIKit

class AdoptListViewController: UIViewController {
    
    let viewModel = AdoptListViewModel()
    
    var isLogin = false
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.dataSource = self
            
            collectionView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        viewModel.petViewModels.bind { [weak self] pets in
            
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.fetchPet { error in
            
            if error != nil {
                
                print(error)
            }
        }
        
        
    }
    
    private func setupCollectionView() {
        
        collectionView.registerCellWithIdentifier(identifier: AdoptCollectionViewCell.identifier)
        
        setupCollectionViewLayout()
    }
    
    private func setupCollectionViewLayout() {

        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.itemSize = CGSize(
            width: Int(164.0 / 375.0 * UIScreen.main.bounds.width),
            height: 400
        )

        flowLayout.sectionInset = UIEdgeInsets(top: 24.0, left: 16.0, bottom: 24.0, right: 16.0)

        flowLayout.minimumInteritemSpacing = 0

        flowLayout.minimumLineSpacing = 24.0

        collectionView.collectionViewLayout = flowLayout
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
        
        cell.addToFavoriteHandler = {
            
            StorageManager.shared.savePetInFavorite(with: cellViewModel)
        }
        
        cell.configureCell(with: cellViewModel)
        
        return cell
    }

}
