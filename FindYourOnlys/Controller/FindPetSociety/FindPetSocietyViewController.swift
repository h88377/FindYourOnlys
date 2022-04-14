//
//  FindPetSocietyViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class FindPetSocietyViewController: UIViewController {
    
    let viewModel = FindPetSocietyViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        
        viewModel.articleViewModels.bind { [weak self] _ in
            
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
    
    func setupTableView() {
        
//        tableView.registerCellWithIdentifier(identifier: ArticleTableViewCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticlePhotoCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: ArticleContentCell.identifier)
        
    }
    
    func convertDataSourceIndex(with index: Int, count: Int) -> Int {
        
        Int(index / count)
    }
    
    @IBAction func addArticle(_ sender: UIButton) {
        
        let storyboard = UIStoryboard.findPetSociety
        
        guard
            let publishVC = storyboard.instantiateViewController(withIdentifier: PublishViewController.identifier) as? PublishViewController
//                ,
//            let uploadTestVC = storyboard.instantiateViewController(withIdentifier: UploadTestViewController.identifier) as? UploadTestViewController
//
                
        else { return }
        
        navigationController?.pushViewController(publishVC, animated: true)
//        navigationController?.pushViewController(uploadTestVC, animated: true)
    }
    
}

// MARK: - UITableViewDataSource and Delegate
extension FindPetSocietyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let registeredCellCount = 2
        
        return viewModel.articleViewModels.value.count * registeredCellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let registeredCellCount = 2
        
        let cellViewModel = viewModel.articleViewModels.value[convertDataSourceIndex(with: indexPath.row, count: registeredCellCount)]
        
        switch indexPath.row % 2 {
            
        case 0:
            
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: ArticlePhotoCell.identifier, for: indexPath) as? ArticlePhotoCell
                    
            else { return UITableViewCell() }
            
            cell.configureCell(with: cellViewModel)
            
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
