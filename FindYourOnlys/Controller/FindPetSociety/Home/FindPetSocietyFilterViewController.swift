//
//  PetSocietyFilterViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

class FindPetSocietyFilterViewController: BaseViewController {
    
    let tableView = UITableView()
    
    let viewModel = FindPetSocietyFilterViewModel()
    
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
        
        guard
            let petSocietyVC = navigationController?.viewControllers[0] as? FindPetSocietyViewController,
            viewModel.isValidCondition
                
        else {
            
            showAlertWindow(title: "異常訊息", message: "請填寫全部條件喔！")
            
            return
        }
        
        petSocietyVC.viewModel.fetchArticles(with: viewModel.findPetSocietyFilterCondition)
        
        navigationController?.popViewController(animated: true)
        
    }

}

// MARK: - UITableViewDataSource and Delegate
extension FindPetSocietyFilterViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        viewModel.findPetSocietyFilterCategory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = viewModel.findPetSocietyFilterCategory[indexPath.row].cellForIndexPath(indexPath, tableView: tableView)
        
        guard
            let basicCell = cell as? PublishBasicCell
                
        else { return cell }
        
        basicCell.delegate = self
        
        return basicCell
    }
}

// MARK: - PublishBasicCellDelegate
extension FindPetSocietyFilterViewController: PublishBasicCellDelegate {
    
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