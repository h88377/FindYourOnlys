//
//  DirectionHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import UIKit
import MapKit

class DirectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var informationLabel: UILabel!
    
    @IBOutlet weak var routeLabel: UILabel!
    
    let distanceFormatter = MKDistanceFormatter()
    
    func configureView(with viewModel: DirectionViewModel, route: MKRoute) {
        
        headerLabel.text = viewModel.direction.route.label
        
            let informationComponents = [
                viewModel.direction.totalTravelTime.formatted,
                "• \(distanceFormatter.string(fromDistance: viewModel.direction.totalDistance))"
            ]
        self.informationLabel.text = informationComponents.joined(separator: " ")
        
        routeLabel.text = route.name
    }
}
