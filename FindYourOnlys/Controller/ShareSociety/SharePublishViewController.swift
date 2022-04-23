//
//  SharePublishViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/23.
//

import UIKit

class SharePublishViewController: BaseViewController {
    
    let viewModel = SharePublishViewModel()
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    override var isHiddenTabBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: PublishUserCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishKindCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishSelectionCell.identifier)
        
        tableView.registerCellWithIdentifier(identifier: PublishContentCell.identifier)
    }
    
}

extension SharePublishViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        viewModel.shareContentCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = viewModel.shareContentCategory[indexPath.row].cellForIndexPath(indexPath, tableView: tableView)
        
        guard
            let publishCell = cell as? PublishBasicCell else { return cell }
        
        
        return publishCell
    }
}
