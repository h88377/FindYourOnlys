//
//  FindPetSocietyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class FindPetSocietyViewController: BaseViewController {
    
    // MARK: - Properties
    
    let viewModel = FindPetSocietyViewModel()
    
    @IBOutlet private weak var remindLabel: UILabel! {
        
        didSet {
            
            remindLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var refetchButton: UIButton!
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet private weak var searchItem: UIBarButtonItem! {
        
        didSet {
            
            searchItem.tintColor = .projectIconColor2
        }
    }
    
    @IBOutlet private weak var addArticleButton: UIButton! {
        
        didSet {
            
            addArticleButton.tintColor = .white
            
            addArticleButton.backgroundColor = .projectIconColor2
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.articleViewModels.bind { [weak self] articleViewModels in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
                
                self.tableView.isHidden = articleViewModels.count == 0
                ? true
                : false
            }
        }
        
        viewModel.authorViewModels.bind { [weak self] _ in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
        }
        
        viewModel.signInHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            let storyboard = UIStoryboard.auth
            
            let authVC = storyboard.instantiateViewController(withIdentifier: AuthViewController.identifier)

            authVC.modalPresentationStyle = .custom
            
            authVC.transitioningDelegate = self

            self.present(authVC, animated: true)
        }
        
        setupArticleHandler()
        
        setupLoadingViewHandler()
        
        addCurrentUserObserver()
        
        viewModel.fetchArticles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addArticleButton.makeRound()
    }
    
    // MARK: - Methods and IBActions
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: ArticlePhotoCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticleContentCell.identifier)
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "尋寵物啟示"
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
    
    private func setupArticleHandler() {
        
        viewModel.shareHanlder = { [weak self] _ in
            
            guard
                let self = self else { return }
            
            AlertWindowManager.shared.showShareActivity(at: self)
        }
        
        viewModel.editHandler = { [weak self] articleViewModel, _ in
            
            guard
                let self = self else { return }
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser,
                articleViewModel.article.userId == currentUser.id
                    
            else {
                
                let blockConfirmAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
                    
                    self.viewModel.blockUser(with: articleViewModel)
                }
                
                AlertWindowManager.shared.presentBlockActionSheet(at: self, with: blockConfirmAction)
                
                return
            }
            
            self.presentEditActionSheet(with: articleViewModel)
        }
        
        viewModel.tapAddArticleHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            let storyboard = UIStoryboard.findPetSociety
            
            let publishVC = storyboard
                .instantiateViewController(withIdentifier: PublishViewController.identifier)
            
            self.navigationController?.pushViewController(publishVC, animated: true)
        }
    }
    
    private func presentEditActionSheet(with articleViewModel: ArticleViewModel) {
        
        let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: "編輯文章", style: .default) { [weak self] _ in
            
            let storyboard = UIStoryboard.profile
            
            guard
                let editVC = storyboard.instantiateViewController(
                    withIdentifier: EditArticleViewController.identifier)
                    as? EditArticleViewController,
                let self = self
            
            else { return }
            
            let article = articleViewModel.article
            
            editVC.viewModel.article = article
            
            self.navigationController?.pushViewController(editVC, animated: true)
        }
        
        let cancel = UIAlertAction(title: "取消", style: .cancel)
        
        let deleteAction = UIAlertAction(title: "刪除文章", style: .destructive) { [weak self] _ in
            
            let deleteAlert = UIAlertController(title: "注意!", message: "將刪除此篇文章", preferredStyle: .alert)
            
            let deleteConfirmAction = UIAlertAction(title: "刪除文章", style: .destructive) { [weak self] _ in
                
                self?.viewModel.deleteArticle(with: articleViewModel)
            }
            
            deleteAlert.addAction(cancel)
            
            deleteAlert.addAction(deleteConfirmAction)
            
            self?.present(deleteAlert, animated: true)
            
        }
        
        alert.addAction(editAction)
        
        alert.addAction(deleteAction)
        
        alert.addAction(cancel)
        
        // iPad specific code
        AlertWindowManager.shared.configureIpadAlert(at: self, with: alert)
        
        present(alert, animated: true)
    }
    
    private func addCurrentUserObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidSet),
            name: .didSetCurrentUser, object: nil
        )
    }
    
    private func convertDataSourceIndex(with index: Int, count: Int) -> Int {
        
        Int(index / count)
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchArticles()
    }
    
    @IBAction func addArticle(_ sender: UIButton) {
        
        viewModel.tapAddArticle()
    }
    
    @IBAction func search(_ sender: UIBarButtonItem) {
        
        let storyboard = UIStoryboard.findPetSociety
        
        guard
            let filterVC = storyboard
                .instantiateViewController(withIdentifier: FindPetSocietyFilterViewController.identifier)
                as? FindPetSocietyFilterViewController
                
        else { return }
        
        filterVC.viewModel.findPetSocietyFilterCondition = viewModel.findPetSocietyFilterCondition
        
        navigationController?.pushViewController(filterVC, animated: true)
    }
    
    @IBAction func refetchArticle(_ sender: UIButton) {
        
        viewModel.fetchArticles()
        
        viewModel.findPetSocietyFilterCondition = FindPetSocietyFilterCondition()
    }
}

// MARK: - UITableViewDataSource and Delegate
extension FindPetSocietyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let registeredCellCount = 2
        
        guard
            viewModel.authorViewModels.value.count > 0,
            viewModel.articleViewModels.value.count == viewModel.authorViewModels.value.count
                
        else { return 0 }
        
        return viewModel.articleViewModels.value.count * registeredCellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let registeredCellCount = 2
        
        let cellViewModel = viewModel
            .articleViewModels
            .value[convertDataSourceIndex(with: indexPath.row, count: registeredCellCount)]
        
        let authorCellViewModel = viewModel
            .authorViewModels
            .value[convertDataSourceIndex(with: indexPath.row, count: registeredCellCount)]
        
        switch indexPath.row % registeredCellCount {
            
        case 0:
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ArticlePhotoCell.identifier, for: indexPath)
            
            guard
                let photoCell = cell as? ArticlePhotoCell
                    
            else { return cell }
            
            photoCell.configureCell(with: cellViewModel, authorViewModel: authorCellViewModel)
            
            photoCell.editHandler = { [weak self] in
                
                self?.viewModel.editArticle(with: cellViewModel, authorViewModel: authorCellViewModel)
            }
            
            return photoCell
            
        case 1:
            
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: ArticleContentCell.identifier, for: indexPath)
            
            guard
                let contentCell = cell as? ArticleContentCell
                    
            else { return cell }
            
            contentCell.configureCell(with: cellViewModel)
            
            contentCell.likeArticleHandler = { [weak self] in
                
                self?.viewModel.likeArticle(with: cellViewModel)
            }
            
            contentCell.unlikeArticleHandler = { [weak self] in
                 
                self?.viewModel.unlikeArticle(with: cellViewModel)
            }
            
            contentCell.leaveCommentHandler = { [weak self] in
                
                let storyboard = UIStoryboard.findPetSociety
                
                guard
                    let petSocietyCommentVC = storyboard.instantiateViewController(
                        withIdentifier: PetSocietyCommentViewController.identifier
                    ) as? PetSocietyCommentViewController
                        
                else { return }
                
                petSocietyCommentVC.modalPresentationStyle = .custom
                
                petSocietyCommentVC.transitioningDelegate = self
                
                petSocietyCommentVC.viewModel.selectedArticle = cellViewModel.article
                
                petSocietyCommentVC.viewModel.selectedAuthor = authorCellViewModel.user
                
                self?.present(petSocietyCommentVC, animated: true)
            }
            
            contentCell.shareHandler = { [weak self] in
                
                self?.viewModel.shareArticle(with: cellViewModel)
            }
            
            return contentCell
            
        default:
        
            return UITableViewCell()
        }
    }
}

// MARK: - PublishBasicCellDelegate
extension FindPetSocietyViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangePostType(_ cell: PublishBasicCell, with postType: String) {
        
        viewModel.postTypeChanged(with: postType)
    }
}
