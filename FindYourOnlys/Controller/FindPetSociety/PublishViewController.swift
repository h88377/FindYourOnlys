//
//  PublishViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/12.
//

import UIKit

class PublishViewController: UIViewController {
    
    let viewModel = PublishViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        
    }
    
    func setupTableView() {
        
        tableView.registerCellWithIdentifier(identifier: PublishUserCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishContentCell.identifier)
        
    }
    
    func convertDataSourceIndex(with index: Int, count: Int) -> Int {
        
        Int(index / count)
    }
    
    @IBAction func publish(_ sender: UIBarButtonItem) {
        
        viewModel.tapPublish { error in
            
            if error != nil { print(error) }
        }
    }
    
}

// MARK: - UITableViewDelegate and DataSource
extension PublishViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        let cellViewModels = viewModel.articleViewModels.value

        let publishContentCategory = viewModel.publishContentCategory

        return publishContentCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        let convertIndex = convertDataSourceIndex(with: indexPath.row, count: viewModel.articleViewModels.value.count)
        
//        let cellViewModel = viewModel.article
        
        let publishContentCategory = viewModel.publishContentCategory
        
        guard
            let cell = publishContentCategory[indexPath.row].cellForIndexPath(indexPath, tableView: tableView) as? PublishBasicCell
                
        else { return UITableViewCell() }
        
        cell.delegate = self
        
        return cell
        
    }
    
}

// MARK: - PublishSelectionCellDelegate
extension PublishViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
    
    func didChangePostType(_ cell: PublishBasicCell, with postType: String) {
        
        viewModel.postTypeChanged(with: postType)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChangede(with: petKind)
    }
    
}
