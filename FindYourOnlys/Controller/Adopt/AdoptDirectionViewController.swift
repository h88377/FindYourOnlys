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
            
//            tableView.dataSource = self
        }
    }
    
    var route: Route?
    
    var mapRoutes: [MKRoute] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLabel.text = route?.label
    }
    
    @IBAction func close(_ sender: UIButton) {
        
    }
    
    override func setupTableView() {
        super.setupTableView()
        
        tableView.registerCellWithIdentifier(identifier: DirectionCell.identifier)
    }
    
}

// MARK: - UITableViewDataSource
//extension AdoptDirectionViewController: UITableViewDataSource {
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//}

