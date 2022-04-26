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
            
            chatButton.tintColor = .projectTintColor
        }
    }
    
    @IBOutlet weak var addFriendButton: UIButton! {
        
        didSet {
            
            addFriendButton.tintColor = .projectTintColor
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
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                errorViewModel?.error != nil else { return }
            
            print(errorViewModel?.error.localizedDescription)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
            
            return cell
            
        default:
        
            return UITableViewCell()
        }
    }
}
