//
//  FindPetSocietyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class FindPetSocietyViewController: BaseViewController {
    
    let viewModel = FindPetSocietyViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var chatButton: UIButton! {
        
        didSet {
            
            chatButton.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var addFriendButton: UIButton! {
        
        didSet {
            
            addFriendButton.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var searchButton: UIButton! {
        
        didSet {
            
            searchButton.tintColor = .systemGray2
        }
    }
    
    @IBOutlet weak var addArticleButton: UIButton! {
        
        didSet {
            
            addArticleButton.tintColor = .systemGray2
            
            addArticleButton.backgroundColor = .darkGray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        viewModel.fetchArticles { error in
            
            guard
                error == nil
            
            else {
                
                print(error)
                
                return
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addArticleButton.layer.cornerRadius = addArticleButton.frame.height / 2
    }
    
    override func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: ArticlePhotoCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticleContentCell.identifier)
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "尋寵物啟示"
    }
    
    func convertDataSourceIndex(with index: Int, count: Int) -> Int {
        
        Int(index / count)
    }
    
    @IBAction func addArticle(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.findPetSociety
        
        guard
            let publishVC = storyboard.instantiateViewController(withIdentifier: PublishViewController.identifier) as? PublishViewController
                
        else { return }
        
        navigationController?.pushViewController(publishVC, animated: true)
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
            let addFriendVC = storyboard.instantiateViewController(withIdentifier: AddFriendViewController.identifier) as? AddFriendViewController
                
        else { return }
        
        navigationController?.pushViewController(addFriendVC, animated: true)
    }
    
}

// MARK: - UITableViewDataSource and Delegate
extension FindPetSocietyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let registeredCellCount = 2
        
        guard
            viewModel.authorViewModels.value.count > 0 else { return 0 }
        
        return viewModel.articleViewModels.value.count * registeredCellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let registeredCellCount = 2
        
        let cellViewModel = viewModel.articleViewModels.value[convertDataSourceIndex(with: indexPath.row, count: registeredCellCount)]
        
        let authorCellViewModel = viewModel.authorViewModels.value[convertDataSourceIndex(with: indexPath.row, count: registeredCellCount)]
        
        switch indexPath.row % 2 {
            
        case 0:
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: ArticlePhotoCell.identifier, for: indexPath) as? ArticlePhotoCell
                    
            else { return UITableViewCell() }
            
            cell.configureCell(with: cellViewModel, authorViewModel: authorCellViewModel)
            
            return cell
            
        case 1:
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: ArticleContentCell.identifier, for: indexPath) as? ArticleContentCell
                    
            else { return UITableViewCell() }
            
            cell.configureCell(with: cellViewModel)
            
            return cell
            
        default:
        
            return UITableViewCell()
        }
    }
}
