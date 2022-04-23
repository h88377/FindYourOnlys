//
//  PetSocietyFilterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

class PetSocietyFilterViewController: BaseViewController {
    
    let tableView = UITableView()
    
    let viewModel = PetSocietyFilterViewModel()
    
    override var isHiddenTabBar: Bool { return true }

    
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
        
        print(viewModel.petSocietyFilterCondition)
    }

}

// MARK: - UITableViewDataSource and Delegate
extension PetSocietyFilterViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        viewModel.petSocietyFilterCategory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = viewModel.petSocietyFilterCategory[indexPath.row].cellForIndexPath(indexPath, tableView: tableView)
        
        guard
            let basicCell = cell as? PublishBasicCell
                
        else { return cell }
        
        basicCell.delegate = self
        
        return basicCell
    }
}

// MARK: - PublishBasicCellDelegate
extension PetSocietyFilterViewController: PublishBasicCellDelegate {
    
    func didChangeCity(_ cell: PublishBasicCell, with city: String) {
        
        viewModel.cityChanged(with: city)
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
        
        viewModel.colorChanged(with: color)
    }
    
    func didChangePetKind(_ cell: PublishBasicCell, with petKind: String) {
        
        viewModel.petKindChanged(with: petKind)
    }
    
    func didChangePostType(_ cell: PublishBasicCell, with postType: String) {
        
        viewModel.postTypeChanged(with: postType)
    }
}
