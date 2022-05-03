//
//  ProfileArticleViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/28.
//

import UIKit

class ProfileSelectedArticleViewController: BaseViewController {
    
    var viewModel = ProfileSelectedArticleViewModel()

    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.backgroundColor = .projectBackgroundColor
            
            tableView.separatorColor = .projectBackgroundColor
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchArticle()
        
        viewModel.articleViewModel.bind { [weak self] _ in
            
            DispatchQueue.main.async {
                
                self?.tableView.reloadData()
            }
        }
        viewModel.errorViewModel.bind { errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            print(errorViewModel?.error.localizedDescription)
        }
        
        viewModel.shareHanlder = { [weak self] articleViewModel in
            
            guard
                let self = self else { return }
            
            // Generate the screenshot
            UIGraphicsBeginImageContext(self.view.frame.size)
            
            self.view.layer.render(in: UIGraphicsGetCurrentContext()!)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            let items: [Any] = [image]
            
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            
            self.present(activityVC, animated: true)
        }
        
        viewModel.editHandler = { [weak self] articleViewModel, _ in
            
            guard
                let currentUser = UserFirebaseManager.shared.currentUser,
                articleViewModel.article.userId == currentUser.id
                    
            else {
                
                self?.showAlertWindow(title: "只有作者才能夠編輯文章喔！", message: "")
                
                return
            }
            
            let alert = UIAlertController(title: "請選擇要執行的項目", message: nil, preferredStyle: .actionSheet)
            
            let editAction = UIAlertAction(title: "編輯文章", style: .default) { [weak self] _ in
                
                let storyboard = UIStoryboard.profile
                
                guard
                    let editVC = storyboard.instantiateViewController(
                        withIdentifier: EditArticleViewController.identifier)
                        as? EditArticleViewController,
                    let self = self,
                    let article = self.viewModel.articleViewModel.value?.article
                
                else { return }
                
//                editVC.viewModel = EditArticleViewModel(model: article)
                editVC.viewModel.article = article
                
                self.navigationController?.pushViewController(editVC, animated: true)
            }
            
            let cancel = UIAlertAction(title: "取消", style: .cancel)
            
            let deleteAction = UIAlertAction(title: "刪除文章", style: .destructive) { [weak self] _ in
                
                let deleteAlert = UIAlertController(title: "注意!", message: "將刪除此篇文章", preferredStyle: .alert)
                
                let deleteConfirmAction = UIAlertAction(title: "刪除文章", style: .destructive) { [weak self] _ in
                    
                    self?.viewModel.deleteArticle()
                }
                
                deleteAlert.addAction(cancel)
                
                deleteAlert.addAction(deleteConfirmAction)
                
                self?.present(deleteAlert, animated: true)
                
            }
            
            alert.addAction(editAction)
            
            alert.addAction(deleteAction)
            
            alert.addAction(cancel)
            
            self?.present(alert, animated: true)
        }
        
        viewModel.dismissHandler = { [weak self] in
            
            DispatchQueue.main.async {
                
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
        viewModel.startLoadingHandler = { [weak self] in

            guard
                let self = self else { return }
            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.startLoading(at: self.view)
            }
        }
        
        viewModel.stopLoadingHandler = {

            DispatchQueue.main.async {

                LottieAnimationWrapper.shared.stopLoading()
            }
        }
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: ArticlePhotoCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticleContentCell.identifier)
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
                
                self?.viewModel.editArticle(with: articleCellViewModel, authorViewModel: UserViewModel(model: currentUser))
            }
            
            articlePhotoCell.showEditButton()
            
            return articlePhotoCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleContentCell.identifier, for: indexPath)
            
            guard
                let articleContentCell = cell as? ArticleContentCell
                    
            else { return cell }
            
            articleContentCell.configureCell(with: articleCellViewModel)
            
            articleContentCell.likeArticleHandler = { [weak self] in
                
                self?.viewModel.likeArticle(with: articleCellViewModel)
            }
            
            articleContentCell.unlikeArticleHandler = { [weak self] in
                 
                self?.viewModel.unlikeArticle(with: articleCellViewModel)
            }
            
            articleContentCell.leaveCommentHandler = { [weak self] in
                
                let storyboard = UIStoryboard.findPetSociety
                
                guard
                    let petSocietyCommentVC = storyboard.instantiateViewController(withIdentifier: PetSocietyCommentViewController.identifier) as? PetSocietyCommentViewController
                        
                else { return }
                
                petSocietyCommentVC.modalPresentationStyle = .custom
                
                petSocietyCommentVC.transitioningDelegate = self
                
                petSocietyCommentVC.viewModel.selectedArticle = articleCellViewModel.article
                
                petSocietyCommentVC.viewModel.selectedAuthor = currentUser
                
                self?.present(petSocietyCommentVC, animated: true)
            }
            
            articleContentCell.shareHandler = { [weak self] in
                
                self?.viewModel.shareArticle(with: articleCellViewModel)
            }
            
            return articleContentCell
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ProfileSelectedArticleViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
