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
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
            
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var closeButton: UIButton! {
        
        didSet {
            
            closeButton.tintColor = .projectTintColor
        }
    }
    
    let viewModel = AdoptDirectionViewModel()
    
    var closeHandler: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.directionViewModel.bind(listener: { [weak self] directionViewModel in
            
            guard
                let self = self else { return }
            
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
        })
    }
    
    @IBAction func close(_ sender: UIButton) {
        
        closeHandler?()
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: DirectionCell.identifier)
        
        tableView.register(UINib(nibName: "\(DirectionHeaderView.self)", bundle: nil), forHeaderFooterViewReuseIdentifier: "\(DirectionHeaderView.self)")
    }
}

// MARK: - UITableViewDataSource
extension AdoptDirectionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let directionViewModel = viewModel.directionViewModel
        
        return directionViewModel.value.direction.mapRoutes.isEmpty ? 0 : directionViewModel.value.direction.mapRoutes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let directionViewModel = viewModel.directionViewModel
        
        let route = directionViewModel.value.direction.mapRoutes[section]
        
        return route.steps.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DirectionCell.identifier, for: indexPath) as? DirectionCell
                
        else { return UITableViewCell() }
        
        let directionViewModel = viewModel.directionViewModel
        
        cell.configureCell(with: directionViewModel.value, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(DirectionHeaderView.self)") as? DirectionHeaderView
                
        else { return nil }
        
        let route = viewModel.directionViewModel.value.direction.mapRoutes[section]
        
        headerView.configureView(with: viewModel.directionViewModel.value, route: route)
        
        return headerView
    }
}

