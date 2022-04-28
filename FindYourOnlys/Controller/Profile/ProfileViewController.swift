//
//  ProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit
import FirebaseAuth

class ProfileViewController: BaseViewController {

    let viewModel = ProfileViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.delegate = self
            
            collectionView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchProfileArticle()
        
        viewModel.profileArticleViewModels.bind { [weak self] _ in
            
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            if
                let deleteDataError = errorViewModel?.error as? DeleteDataError {
                
                self?.showAlertWindow(title: "異常", message: deleteDataError.errorMessage)
                
            } else if
                
                let deleteAccountError = errorViewModel?.error as? DeleteAccountError {
                
                self?.showAlertWindow(title: "異常", message: deleteAccountError.errorMessage)
                
            }
        }
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView.registerCellWithIdentifier(identifier: ProfileArticleCell.identifier)
        
        setupCollectionViewLayout()
    }
    
    private func setupCollectionViewLayout() {

        let flowLayout = UICollectionViewFlowLayout()

        flowLayout.itemSize = CGSize(
            width: Int((UIScreen.main.bounds.width - 32 - 10) / 3),
            height: Int((UIScreen.main.bounds.width - 32 - 10) / 3)
        )

        flowLayout.sectionInset = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)

        flowLayout.minimumInteritemSpacing = 5

        flowLayout.minimumLineSpacing = 5

        collectionView.collectionViewLayout = flowLayout
    }
    
    @IBAction func goToFriendRequest(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.profile
        
        let friendRequestVC = storyboard.instantiateViewController(
            withIdentifier: ProfileFriendRequestViewController.identifier)
        
        navigationController?.pushViewController(friendRequestVC, animated: true)
    }
    
    @IBAction func signOut(_ sender: UIButton) {
        
        viewModel.signOut()
    }
    
    @IBAction func showAuth(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.auth
        
        let authVC = storyboard.instantiateViewController(
            withIdentifier: AuthViewController.identifier)
        
        authVC.modalPresentationStyle = .custom
        
        authVC.transitioningDelegate = self
        
        present(authVC, animated: true)
    }
    
    @IBAction func deleteUser(_ sender: UIButton) {
        
        showDeleteWindow(title: "警告", message: "您將刪除個人帳號，確定要刪除帳號嗎？")
    }
    
    func showDeleteWindow(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "刪除", style: .destructive) { [weak self] _ in
            
            self?.viewModel.deleteUser()
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        alert.addAction(cancel)
        
        alert.addAction(delete)
        
        present(alert, animated: true)
    }
    
}

// MARK: - UICollectionViewDataSource and Delegate
extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        viewModel.profileArticleViewModels.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        viewModel.profileArticleViewModels.value[section].profileArticle.articles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileArticleCell.identifier, for: indexPath)
        
        guard
            let profileArticleCell = cell as? ProfileArticleCell else { return cell }
        
        let article = viewModel.profileArticleViewModels.value[indexPath.section].profileArticle.articles[indexPath.row]
        
        profileArticleCell.configureCell(with: article)
        
        return profileArticleCell
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
