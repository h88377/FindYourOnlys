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
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userEmailLabel: UILabel! {
        
        didSet {
            
            userEmailLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        
        didSet {
            
            editButton.setTitleColor(.white, for: .normal)
            
            editButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            editButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var userNickNameLabel: UILabel! {
        
        didSet {
            
            userNickNameLabel.textColor = .projectTextColor
            
            userNickNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.delegate = self
            
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.startLoadingHandler = { [weak self] in

            self?.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in

            self?.stopLoading()
        }
        
        viewModel.fetchCurrentUser()
        
        viewModel.fetchProfileArticle()
        
        addCurrentUserObserver()
        
        viewModel.userViewModel.bind { [weak self] userViewModel in
            
            guard
                let userViewModel = userViewModel else { return }
            
            DispatchQueue.main.async {
                
                self?.setupProfile(with: userViewModel)
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
                        let authError = error as? AuthError {
                        
                        self?.showAlertWindow(title: "異常", message: "\(authError.errorMessage)")
                    }
                }
            }
        }
        
        viewModel.profileArticleViewModels.bind { [weak self] profileArticleViewModels in
            
            DispatchQueue.main.async {
                
                self?.collectionView.isHidden = profileArticleViewModels
                    .flatMap { $0.profileArticle.articles }
                    .count == 0
                
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.backToHomeHandler = { [weak self] in
            
            self?.tabBarController?.selectedIndex = 0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        
        editButton.layer.cornerRadius = 12
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "個人頁"
        
        let barButtonItem = UIBarButtonItem(title: "登出", style: .done, target: self, action: #selector(signOut))
        
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    override func setupCollectionView() {
        super.setupCollectionView()
        
        collectionView.registerCellWithIdentifier(identifier: ProfileArticleCell.identifier)
        
        collectionView.registerHeaderViewWithIdentifier(identifier: ProfileArticleHeaderView.getIdentifier())
        
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
    
    func setupProfile(with userViewModel: UserViewModel) {
                
        let currentUser = userViewModel.user
        
        userImageView.loadImage(currentUser.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userEmailLabel.text = currentUser.email
        
        userNickNameLabel.text = currentUser.nickName
    }
    
    @objc func signOut(sender: UIBarButtonItem) {
        
        let signOutAlert = UIAlertController(title: "即將登出", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        let signOut = UIAlertAction(title: "登出", style: .destructive) { [weak self] _ in
            
            self?.viewModel.signOut()
        }
        signOutAlert.addAction(signOut)
        
        signOutAlert.addAction(cancel)
        
        // iPad specific code
        signOutAlert.popoverPresentationController?.sourceView = self.view
        
        let xOrigin = self.view.bounds.width / 2
        
        let popoverRect = CGRect(x: xOrigin, y: 0, width: 1, height: 1)
        
        signOutAlert.popoverPresentationController?.sourceRect = popoverRect
        
        signOutAlert.popoverPresentationController?.permittedArrowDirections = .up
        
        present(signOutAlert, animated: true)
    }
    
    private func addCurrentUserObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidSet),
            name: .didSetCurrentUser, object: nil
        )
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchCurrentUser()
        
        viewModel.fetchProfileArticle()
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.profile
        
        let viewController = storyboard.instantiateViewController(withIdentifier: EditProfileViewController.identifier)
        
        guard
            let editProfileVC = viewController as? EditProfileViewController else { return }
        
        editProfileVC.viewModel.currentUser = UserFirebaseManager.shared.currentUser
        
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource and Delegate
extension ProfileViewController: UICollectionViewDataSource,  UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        viewModel.profileArticleViewModels.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        viewModel.profileArticleViewModels.value[section].profileArticle.articles.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileArticleCell.identifier,
            for: indexPath
        )
        
        guard
            let profileArticleCell = cell as? ProfileArticleCell else { return cell }
        
        let article = viewModel.profileArticleViewModels.value[indexPath.section].profileArticle.articles[indexPath.row]
        
        profileArticleCell.configureCell(with: article)
        
        return profileArticleCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath)
    -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ProfileArticleHeaderView.getIdentifier(),
            for: indexPath
        )
        
        guard
            let profileArticleHeaderView = headerView as? ProfileArticleHeaderView
                
        else { return headerView }
        
        let cellViewModel = viewModel.profileArticleViewModels.value[indexPath.section]
        
        profileArticleHeaderView.configureView(with: cellViewModel.profileArticle)
        
        return profileArticleHeaderView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int)
    -> CGSize {
        
        CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.profile
        
        guard
            let profileSelectedArticleVC = storyboard.instantiateViewController(
                withIdentifier: ProfileSelectedArticleViewController.identifier)
                as? ProfileSelectedArticleViewController
        
        else { return }
        
        
        profileSelectedArticleVC.viewModel.articleViewModel.value = ArticleViewModel(
            model: viewModel
                .profileArticleViewModels
                .value[indexPath.section]
                .profileArticle.articles[indexPath.row]
        )
        
//        profileSelectedArticleVC.viewModel.authorViewModel.value = authorViewModel
        
        navigationController?.pushViewController(profileSelectedArticleVC, animated: true)
    }
    
}

// UICollectionViewCompositionalLayout


//        collectionView.collectionViewLayout = configureCollectionViewLayout()


//    func configureCollectionViewLayout() -> UICollectionViewCompositionalLayout {
//
//        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
//
//          let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
//          let item = NSCollectionLayoutItem(layoutSize: itemSize)
//          item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//
//          let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .fractionalHeight(0.3))
//          let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
//
//          let section = NSCollectionLayoutSection(group: group)
//          section.orthogonalScrollingBehavior = .groupPaging
//          section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
//          section.interGroupSpacing = 10
//
//          let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
//          let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
//          section.boundarySupplementaryItems = [sectionHeader]
//
//          return section
//        }
//        let sectionProvider = { (
//            sectionIndex: Int,
//            layoutEnvironment: NSCollectionLayoutEnvironment)
//            -> NSCollectionLayoutSection? in
//
//            let itemSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .fractionalHeight(1.0)
//            )
//
//            let item = NSCollectionLayoutItem(layoutSize: itemSize)
//
//            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
//
//            let groupSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1 / 3),
//                heightDimension: .fractionalHeight(0.75)
//            )
//
//            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
//
//            let section = NSCollectionLayoutSection(group: group)
//
//            section.interGroupSpacing = 8
//
//            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
//
//            section.orthogonalScrollingBehavior = .groupPaging
//
//            let headerSize = NSCollectionLayoutSize(
//                widthDimension: .fractionalWidth(1.0),
//                heightDimension: .estimated(44)
//            )
//
//            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
//                layoutSize: headerSize,
//                elementKind: UICollectionView.elementKindSectionHeader,
//                alignment: .topLeading
//            )
//
//            section.boundarySupplementaryItems = [sectionHeader]
//
//            return section
//        }
    
//        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
//    }
