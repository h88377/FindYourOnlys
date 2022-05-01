//
//  ShareSocietyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

class ShareSocietyViewController: BaseViewController {
    
    let viewModel = ShareSocietyViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var addArticleButton: UIButton! {
        
        didSet {
            
            addArticleButton.tintColor = .systemGray2
            
            addArticleButton.backgroundColor = .darkGray
        }
    }
    @IBOutlet weak var chatButton: UIButton! {
        
        didSet {
            
            chatButton.tintColor = .projectPlaceHolderColor
        }
    }
    
    @IBOutlet weak var addFriendButton: UIButton! {
        
        didSet {
            
            addFriendButton.tintColor = .projectPlaceHolderColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchSharedArticles()
        
        viewModel.articleViewModels.bind { [weak self] _ in
            
            DispatchQueue.main.async {
                
                self?.tableView.reloadData()
            }
            
        }
        
        viewModel.authorViewModels.bind { [weak self] _ in
            
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addArticleButton.layer.cornerRadius = addArticleButton.frame.height / 2
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        navigationItem.title = "分享牆"
        
        tableView.registerCellWithIdentifier(identifier: ArticlePhotoCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticleContentCell.identifier)
    }
    
    private func convertDataSourceIndex(with index: Int, count: Int) -> Int {
        
        Int(index / count)
    }

    @IBAction func publish(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.shareSociety
        
        let shareSocietyVC = storyboard.instantiateViewController(withIdentifier: SharePublishViewController.identifier)
        
        navigationController?.pushViewController(shareSocietyVC, animated: true)
    }
    
    @IBAction func goToChat(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.findPetSociety
        
        guard
            let chatRoomFriendListVC = storyboard.instantiateViewController(withIdentifier: ChatRoomFriendListViewController.identifier) as? ChatRoomFriendListViewController
                
        else { return }
        
        navigationController?.pushViewController(chatRoomFriendListVC, animated: true)
    }
    
    @IBAction func addFriend(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.findPetSociety
        
        guard
            let addFriendVC = storyboard
                .instantiateViewController(withIdentifier: AddFriendViewController.identifier)
                as? AddFriendViewController
                
        else { return }
        
        navigationController?.pushViewController(addFriendVC, animated: true)
    }
    
}

// MARK: - ShareSocietyViewController UITableViewDelegate and DataSource
extension ShareSocietyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let registeredCellCount = 2
        
        guard
            viewModel.authorViewModels.value.count > 0,
            viewModel.articleViewModels.value.count == viewModel.authorViewModels.value.count
                
        else { return 0 }
        
        return viewModel.articleViewModels.value.count * registeredCellCount
    }
    
    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let registeredCellCount = 2
        
        let cellViewModel = viewModel
            .articleViewModels
            .value[convertDataSourceIndex(with: indexPath.row, count: registeredCellCount)]
        
        let authorCellViewModel = viewModel
            .authorViewModels
            .value[convertDataSourceIndex(with: indexPath.row, count: registeredCellCount)]
        
        switch indexPath.row % 2 {
            
        case 0:
            
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ArticlePhotoCell.identifier, for: indexPath)
                    as? ArticlePhotoCell
                    
            else { return UITableViewCell() }
            
            cell.configureCell(with: cellViewModel, authorViewModel: authorCellViewModel)
            
            return cell
            
        case 1:
            
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: ArticleContentCell.identifier, for: indexPath)
                    as? ArticleContentCell
                    
            else { return UITableViewCell() }
            
            cell.configureCell(with: cellViewModel)
            
            cell.likeArticleHandler = { [weak self] in
                
                self?.viewModel.likeArticle(with: cellViewModel)
            }
            
            cell.unlikeArticleHandler = { [weak self] in
                 
                self?.viewModel.unlikeArticle(with: cellViewModel)
            }
            
            cell.leaveCommentHandler = { [weak self] in
                
                let storyboard = UIStoryboard.findPetSociety
                
                guard
                    let petSocietyCommentVC = storyboard.instantiateViewController(withIdentifier: PetSocietyCommentViewController.identifier) as? PetSocietyCommentViewController
                        
                else { return }
                
                petSocietyCommentVC.modalPresentationStyle = .custom
                
                petSocietyCommentVC.transitioningDelegate = self
                
                petSocietyCommentVC.viewModel.selectedArticle = cellViewModel.article
                
                petSocietyCommentVC.viewModel.selectedAuthor = authorCellViewModel.user
                
                self?.present(petSocietyCommentVC, animated: true)
            }
            
            cell.shareHandler = { [weak self] in
                
                self?.viewModel.shareArticle(with: cellViewModel)
            }
            
            return cell
            
        default:
        
            return UITableViewCell()
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ShareSocietyViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
