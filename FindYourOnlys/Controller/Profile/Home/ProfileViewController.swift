//
//  ProfileViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/18.
//

import UIKit
import FirebaseAuth

class ProfileViewController: BaseViewController {

    // MARK: - Properties
    
    private let viewModel = ProfileViewModel()
    
    @IBOutlet private weak var userImageView: UIImageView!
    
    @IBOutlet private weak var userEmailLabel: UILabel! {
        
        didSet {
            
            userEmailLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var editButton: UIButton! {
        
        didSet {
            
            editButton.setTitleColor(.white, for: .normal)
            
            editButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            editButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var userNickNameLabel: UILabel! {
        
        didSet {
            
            userNickNameLabel.textColor = .projectTextColor
            
            userNickNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        
        didSet {
            
            collectionView.delegate = self
            
            collectionView.dataSource = self
        }
    }
    
    @IBOutlet private weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
   
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.user.bind { [weak self] user in
            
            guard
                let user = user,
                let self = self
            else { return }
            
            self.setupProfile(with: user)
        }
        
        viewModel.error.bind { [weak self] error in

            guard let self = self,
                  let error = error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
        
        viewModel.profileArticles.bind { [weak self] profileArticles in
            
            guard let self = self else { return }
            
            self.collectionView.isHidden = profileArticles
                .flatMap { $0.articles }
                .isEmpty
            
            self.collectionView.reloadData()
        }
        
        viewModel.backToHomeHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.tabBarController?.selectedIndex = 0
        }
        
        addCurrentUserObserver()
        
        viewModel.fetchCurrentUser()
        
        viewModel.fetchProfileArticle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        userImageView.makeRound()
        
        editButton.layer.cornerRadius = 12
    }
    
    // MARK: - Methods and IBActions
    
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
            height: Int((UIScreen.main.bounds.width - 32 - 10) / 3))

        flowLayout.sectionInset = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)

        flowLayout.minimumInteritemSpacing = 5

        flowLayout.minimumLineSpacing = 5

        collectionView.collectionViewLayout = flowLayout
    }
    
    override func setupLoadingViewHandler() {
        
        viewModel.startLoadingHandler = { [weak self] in

            guard let self = self else { return }
            
            self.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in

            guard let self = self else { return }
            
            self.stopLoading()
        }
    }
    
    private func setupProfile(with user: User) {
        
        userImageView.loadImage(user.imageURLString, placeHolder: UIImage.system(.personPlaceHolder))
        
        userEmailLabel.text = user.email
        
        userNickNameLabel.text = user.nickName
    }
    
    @objc private func signOut(sender: UIBarButtonItem) {
        
        let signOutAlert = UIAlertController(title: "即將登出", message: nil, preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        let signOut = UIAlertAction(title: "登出", style: .destructive) { [weak self] _ in
            
            self?.viewModel.signOut()
        }
        signOutAlert.addAction(signOut)
        
        signOutAlert.addAction(cancel)
        
        // iPad specific code
        AlertWindowManager.shared.configureIpadAlert(at: self, with: signOutAlert)
        
        present(signOutAlert, animated: true)
    }
    
    private func addCurrentUserObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidSet),
            name: .didSetCurrentUser, object: nil)
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchCurrentUser()
        
        viewModel.fetchProfileArticle()
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.profile
        
        let viewController = storyboard.instantiateViewController(withIdentifier: EditProfileViewController.identifier)
        
        guard let editProfileVC = viewController as? EditProfileViewController else { return }
        
        editProfileVC.viewModel.currentUser = UserFirebaseManager.shared.currentUser
        
        navigationController?.pushViewController(editProfileVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource and Delegate

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let profileArticleTypeCount = viewModel.profileArticles.value.count
        
        return profileArticleTypeCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let profileArticleCount = viewModel.profileArticles.value[section].articles.count
        
        return profileArticleCount
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProfileArticleCell.identifier,
            for: indexPath)
        
        guard let profileArticleCell = cell as? ProfileArticleCell else { return cell }
        
        let article = viewModel.profileArticles.value[indexPath.section].articles[indexPath.row]
        
        profileArticleCell.configureCell(with: article)
        
        return profileArticleCell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ProfileArticleHeaderView.getIdentifier(),
            for: indexPath)
        
        guard let profileArticleHeaderView = headerView as? ProfileArticleHeaderView else {
            
            return headerView
        }
        
        let profileArticle = viewModel.profileArticles.value[indexPath.section]
        
        profileArticleHeaderView.configureView(with: profileArticle)
        
        return profileArticleHeaderView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        CGSize(width: collectionView.frame.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard.profile
        
        guard
            let profileSelectedArticleVC = storyboard.instantiateViewController(
                withIdentifier: ProfileSelectedArticleViewController.identifier
            )as? ProfileSelectedArticleViewController
        
        else { return }
        
        profileSelectedArticleVC.viewModel.profileSelectedArticle.value = viewModel
            .profileArticles
            .value[indexPath.section]
            .articles[indexPath.row]
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        navigationController?.pushViewController(profileSelectedArticleVC, animated: true)
    }
}
