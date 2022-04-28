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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
            let authorCellViewModel = viewModel.authorViewModel.value
                
        else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ArticlePhotoCell.identifier, for: indexPath)
            guard
                let articlePhotoCell = cell as? ArticlePhotoCell
                    
            else { return cell }
            
            articlePhotoCell.configureCell(with: articleCellViewModel, authorViewModel: authorCellViewModel)
            
            return articlePhotoCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ArticleContentCell.identifier, for: indexPath)
            
            guard
                let articleContentCell = cell as? ArticleContentCell
                    
            else { return cell }
            
            articleContentCell.configureCell(with: articleCellViewModel)
            
            return articleContentCell
        }
    }
}
