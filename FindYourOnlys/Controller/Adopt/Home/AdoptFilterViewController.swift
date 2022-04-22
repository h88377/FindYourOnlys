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
        
        let filterButtonItem = UIBarButtonItem(title: "篩選", style: .done, target: self, action: #selector(filter))
        
        navigationItem.rightBarButtonItem = filterButtonItem
    }
    
    @objc func filter(sender: UIBarButtonItem) {
        
        print(viewModel.adoptFilterCondition)
    }
    
}

// MARK: - UITableViewDataSource and Delegate
extension AdoptFilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.adoptFilterCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let adoptFilterCategory = viewModel.adoptFilterCategory
        
        guard
            let cell = adoptFilterCategory[indexPath.row].cellForIndexPath(
                indexPath,
                tableView: tableView
            ) as? PublishBasicCell
                
        else { return UITableViewCell() }
                
        cell.delegate = self
        
        return cell
    }
}

extension AdoptFilterViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangeSex(_ cell: PublishBasicCell, with sex: String) {
        
        viewModel.sexChanged(with: sex)
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
    
        viewModel.colorChanged(with: color)
    }
    
}
