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
    
    override var isHiddenTabBar: Bool { return true }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        tableView.backgroundColor = .projectBackgroundColor
        
        tableView.separatorStyle = .none
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: FilterRemindCell.identifier)
        
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
            let adoptVC = navigationController?.viewControllers[0] as? AdoptViewController,
            viewModel.isValidCondition
                
        else {
            
            showAlertWindow(title: "異常訊息", message: "請至少填寫一個條件喔！")
            
            return
        }
        
        adoptVC.adoptListVC?.viewModel.resetFilterCondition()
        
        adoptVC.adoptListVC?.viewModel.filterConditionViewModel.value = viewModel.adoptFilterCondition
        
        adoptVC.adoptListVC?.viewModel.resetFetchPet()
        
        adoptVC.viewModel.adoptFilterCondition = viewModel.adoptFilterCondition
        
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource and Delegate
extension AdoptFilterViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.adoptFilterCategory.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let adoptFilterCategory = viewModel.adoptFilterCategory
        
        if indexPath.row + 1 <= adoptFilterCategory.count {
            
            let cell = adoptFilterCategory[indexPath.row].cellForIndexPath(
                indexPath,
                tableView: tableView,
                condition: viewModel.adoptFilterCondition
            )
            
            guard
                let basicCell = cell as? PublishBasicCell
                    
            else { return cell }
            
            basicCell.delegate = self
            
            basicCell.selectionStyle = .none
            
            return basicCell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FilterRemindCell.identifier, for: indexPath)
            
            guard
                let remindCell = cell as? FilterRemindCell
            
            else { return cell }
            
            remindCell.configureCell(with: .allowOneCondition)
            
            return remindCell
        }
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
        
        if sex == Sex.male.rawValue {
            
            viewModel.sexChanged(with: "M")
            
        } else {
            
            viewModel.sexChanged(with: "F")
        }
    }
    
    func didChangeColor(_ cell: PublishBasicCell, with color: String) {
    
        viewModel.colorChanged(with: color)
    }
    
}
