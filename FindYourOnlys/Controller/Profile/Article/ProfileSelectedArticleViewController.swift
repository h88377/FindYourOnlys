//
//  ProfileArticleViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import UIKit

class ProfileSelectedArticleViewController: BaseViewController {
    
    // MARK: - Properties
    
    var viewModel = PetSocietyViewModel()

    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.backgroundColor = .projectBackgroundColor
            
            tableView.separatorStyle = .none
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.articleViewModel.bind { [weak self] _ in
            
            guard
                let self = self else { return }
            
            self.tableView.reloadData()
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                
                AlertWindowManager.shared.showAlertWindow(at: self, of: error)
            }
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.popBack()
        }
        
        viewModel.editHandler = { [weak self] articleViewModel in
            
            guard
                let self = self else { return }
            
            let deleteConfirmAction = UIAlertAction(title: "刪除文章", style: .destructive) { [weak self] _ in
                
                self?.viewModel.deleteArticle(with: articleViewModel)
            }
            
            AlertWindowManager.shared.presentEditActionSheet(
                at: self,
                articleViewModel: articleViewModel,
                with: deleteConfirmAction
            )
        }
        
        viewModel.fetchArticle()
    }
    
    // MARK: - Method
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: ArticlePhotoCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticleContentCell.identifier)
    }
    
    override func setupLoadingViewHandler() {
        
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
    
    private func setupArticleContentCellHandler(
        articleCell: ArticleContentCell,
        with articleViewModel: ArticleViewModel,
        author: User
    ) {
        
        articleCell.likeArticleHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.viewModel.likeArticle(with: articleViewModel)
        }
        
        articleCell.unlikeArticleHandler = { [weak self] in
            
            guard
                let self = self else { return }
             
            self.viewModel.unlikeArticle(with: articleViewModel)
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
            
            petSocietyCommentVC.viewModel.selectedArticle = articleViewModel.article
            
            petSocietyCommentVC.viewModel.selectedAuthor = author
            
            self.present(petSocietyCommentVC, animated: true)
        }
        
        articleCell.shareHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            AlertWindowManager.shared.showShareActivity(at: self)
        }
    }
}

// MARK: - UITableViewDataSource and Delegate

extension ProfileSelectedArticleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let articleCellViewModel = viewModel.articleViewModel.value,
            let currentUser = UserFirebaseManager.shared.currentUser
                
        else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ArticlePhotoCell.identifier, for: indexPath)
            
            guard
                let articlePhotoCell = cell as? ArticlePhotoCell
                    
            else { return cell }
            
            articlePhotoCell.configureCell(with: articleCellViewModel)
            
            articlePhotoCell.editHandler = { [weak self] in
                
                self?.viewModel.editArticle(with: articleCellViewModel)
            }
            
            return articlePhotoCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleContentCell.identifier, for: indexPath)
            
            guard
                let articleContentCell = cell as? ArticleContentCell
                    
            else { return cell }
            
            articleContentCell.configureCell(with: articleCellViewModel)
            
            setupArticleContentCellHandler(
                articleCell: articleContentCell,
                with: articleCellViewModel,
                author: currentUser
            )
            
            return articleContentCell
        }
    }
}
