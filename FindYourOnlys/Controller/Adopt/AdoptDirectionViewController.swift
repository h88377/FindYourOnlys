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
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.dataSource = self
        }
    }
    
    let viewModel = AdoptDirectionViewModel()
    
//    var route: Route?
//
//    var mapRoutes: [MKRoute] = []
//
//    private var totalDistance: CLLocationDistance = 0
//
//    private var totalTravelTime: TimeInterval = 0
    
//    private let distanceFormatter = MKDistanceFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.directionViewModel.bind(listener: { [weak self] directionViewModel in
            
            DispatchQueue.main.async {
                
                self?.tableView.reloadData()
                
                self?.headerLabel.text = directionViewModel.direction.route.label
            }
        })
    }
    
    @IBAction func close(_ sender: UIButton) {
        
        
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: DirectionCell.identifier)
    }
    
}

// MARK: - UITableViewDataSource
extension AdoptDirectionViewController: UITableViewDataSource {
    
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let route = viewModel.directionViewModel.value.direction.mapRoutes[section]
        
        return route.name
    }
}

