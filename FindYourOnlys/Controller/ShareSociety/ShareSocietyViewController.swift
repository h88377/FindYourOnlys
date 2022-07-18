//
//  ShareSocietyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

class ShareSocietyViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let viewModel = PetSocietyViewModel()
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.separatorStyle = .none
        }
    }
    
    @IBOutlet private weak var addArticleButton: UIButton! {
        
        didSet {
            
            addArticleButton.tintColor = .white
            
            addArticleButton.backgroundColor = .projectIconColor2
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
        
        viewModel.sharedArticles.bind { [weak self] article in
            
            guard let self = self else { return }
            
            self.tableView.reloadData()
            
            self.tableView.isHidden = article.isEmpty
        }
        
        viewModel.sharedAuthors.bind { [weak self] _ in
            
            guard let self = self else { return }
            
            self.tableView.reloadData()
        }
        
        viewModel.error.bind { [weak self] error in
            
            guard
                let self = self,
                let error = error
            else { return }
            
            AlertWindowManager.shared.showAlertWindow(at: self, of: error)
        }
        
        viewModel.signInHandler = { [weak self] in
            
            let storyboard = UIStoryboard.auth
            
            let authVC = storyboard.instantiateViewController(withIdentifier: AuthViewController.identifier)
            
            authVC.modalPresentationStyle = .custom
            
            authVC.transitioningDelegate = self
            
            self?.present(authVC, animated: true)
        }
        
        setupArticleHandler()
        
        addCurrentUserObserver()
        
        viewModel.fetchSharedArticles()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addArticleButton.makeRound()
    }
    
    // MARK: - Methods and IBActions
    
    override func setupTableView() {
        super.setupTableView()
        
        navigationItem.title = "分享牆"
        
        tableView.registerCellWithIdentifier(identifier: ArticlePhotoCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticleContentCell.identifier)
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
    
    private func setupArticleHandler() {
        
        viewModel.editHandler = { [weak self] article in
            
            guard let self = self else { return }
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser,
                article.userId == currentUser.id
            else {
                
                let blockConfirmAction = UIAlertAction(title: "封鎖", style: .destructive) { _ in
                    
                    self.viewModel.blockUser(with: article)
                }
                
                AlertWindowManager.shared.presentBlockActionSheet(at: self, with: blockConfirmAction)
                
                return
            }
            
            let deleteConfirmAction = UIAlertAction(title: "刪除文章", style: .destructive) { [weak self] _ in
                
                self?.viewModel.deleteArticle(with: article)
            }
            
            AlertWindowManager.shared.presentEditActionSheet(
                at: self,
                article: article,
                with: deleteConfirmAction)
        }
        
        viewModel.tapAddArticleHandler = { [weak self] in
            
            guard let self = self else { return }
            
            let storyboard = UIStoryboard.findPetSociety
            
            guard
                let publishVC = storyboard.instantiateViewController(
                    withIdentifier: PublishViewController.identifier)
                    as? PublishViewController
            else { return }
            
            publishVC.viewModel.articleType = .share
            
            self.navigationController?.pushViewController(publishVC, animated: true)
        }
    }
    
    private func setupArticleContentCellHandler(
        articleCell: ArticleContentCell,
        with article: Article,
        author: User
    ) {
        articleCell.likeArticleHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.viewModel.likeArticle(with: article)
        }
        
        articleCell.unlikeArticleHandler = { [weak self] in
            
            guard let self = self else { return }
            
            self.viewModel.unlikeArticle(with: article)
        }
        
        articleCell.leaveCommentHandler = { [weak self] in
            
            let storyboard = UIStoryboard.findPetSociety
            
            guard
                let petSocietyCommentVC = storyboard.instantiateViewController(
                    withIdentifier: PetSocietyCommentViewController.identifier
                ) as? PetSocietyCommentViewController,
                let self = self
            else { return }
            
            petSocietyCommentVC.modalPresentationStyle = .custom
            
            petSocietyCommentVC.transitioningDelegate = self
            
            petSocietyCommentVC.viewModel.selectedArticle = article
            
            petSocietyCommentVC.viewModel.selectedAuthor = author
            
            self.present(petSocietyCommentVC, animated: true)
        }
        
        articleCell.shareHandler = { [weak self] in
            
            guard let self = self else { return }
            
            AlertWindowManager.shared.showShareActivity(at: self)
        }
    }
    
    private func addCurrentUserObserver() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(currentUserDidSet),
            name: .didSetCurrentUser, object: nil)
    }
    
    @objc private func currentUserDidSet(_ notification: Notification) {
        
        viewModel.fetchSharedArticles()
    }
    
    @IBAction func publish(_ sender: UIButton) {
        
        viewModel.tapAddArticle()
    }
}

// MARK: - ShareSocietyViewController UITableViewDelegate and DataSource
extension ShareSocietyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        guard
            viewModel.sharedAuthors.value.count > 0,
            viewModel.sharedArticles.value.count == viewModel.sharedAuthors.value.count
        else { return 0 }
        
        return viewModel.sharedArticles.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let registeredCellCount = 2
        
        return registeredCellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let article = viewModel
            .sharedArticles
            .value[indexPath.section]
        
        let author = viewModel
            .sharedAuthors
            .value[indexPath.section]
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ArticlePhotoCell.identifier, for: indexPath)
            
            guard let photoCell = cell as? ArticlePhotoCell else { return cell }
            
            photoCell.configureCell(with: article, author: author)
            
            photoCell.editHandler = { [weak self] in
                
                guard let self = self else { return }
                
                self.viewModel.editArticle(with: article)
            }
            
            return photoCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ArticleContentCell.identifier, for: indexPath)
            
            guard let contentCell = cell as? ArticleContentCell else { return cell }
            
            contentCell.configureCell(with: article)
            
            setupArticleContentCellHandler(
                articleCell: contentCell,
                with: article,
                author: author)
            
            return contentCell   
        }
    }
}
