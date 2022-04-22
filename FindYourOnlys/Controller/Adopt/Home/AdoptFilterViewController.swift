//
//  AdoptFilterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/22.
//

import UIKit

class AdoptFilterViewController: BaseViewController {
    
    let tableView = UITableView()
    
    let viewModel = AdoptFilterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                
                tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
                
                tableView.heightAnchor.constraint(equalTo: view.heightAnchor)
            ]
        )
    }
    
    override func setupNavigationTitle() {
        super.setupNavigationTitle()
        
        navigationItem.title = "搜尋條件"
    }
    
}

// MARK: - UITableViewDataSource and Delegate
extension AdoptFilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.adoptFilterCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        viewModel.adoptFilterCategory[indexPath.row].cellForIndexPath(indexPath, tableView: tableView)
    }
}
