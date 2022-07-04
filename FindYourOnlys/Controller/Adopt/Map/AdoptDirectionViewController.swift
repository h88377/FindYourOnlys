//
//  AdoptDirectionViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import Foundation
import UIKit
import MapKit

class AdoptDirectionViewController: BaseViewController {
    
    // MARK: - Properties
    
    let viewModel = AdoptDirectionViewModel()
    
    @IBOutlet private weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
            
            tableView.backgroundColor = .projectBackgroundColor2
        }
    }
    
    @IBOutlet private weak var closeButton: UIButton! {
        
        didSet {
            
            closeButton.tintColor = .white
        }
    }
    
    @IBOutlet private weak var indicatorImageView: UIImageView! {
        
        didSet {
            
            indicatorImageView.tintColor = .white
        }
    }
    
    var closeHandler: (() -> Void)?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.directionViewModel.bind { [weak self] _ in
            
            guard
                let self = self else { return }
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Methods and IBActions
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: DirectionCell.identifier)
        
        tableView.registerViewWithIdentifier(identifier: DirectionHeaderView.identifier)
    }
    
    @IBAction func close(_ sender: UIButton) {
        
        closeHandler?()
    }
}

// MARK: - UITableViewDataSource
extension AdoptDirectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let directionViewModel = viewModel.directionViewModel
        
        return directionViewModel.value.direction.mapRoutes.isEmpty
        ? 0
        : directionViewModel.value.direction.mapRoutes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let directionViewModel = viewModel.directionViewModel
        
        let route = directionViewModel.value.direction.mapRoutes[section]
        
        return route.steps.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DirectionCell.identifier,
            for: indexPath)
        
        guard
            let directionCell = cell as? DirectionCell
                
        else { return cell }
        
        let directionViewModel = viewModel.directionViewModel
        
        directionCell.configureCell(with: directionViewModel.value, at: indexPath)
        
        return directionCell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: DirectionHeaderView.identifier)
                as? DirectionHeaderView
                
        else { return nil }
        
        let route = viewModel.directionViewModel.value.direction.mapRoutes[section]
        
        let directionViewModel = viewModel.directionViewModel
        
        headerView.configureView(with: directionViewModel.value, route: route)
        
        return headerView
    }
}
