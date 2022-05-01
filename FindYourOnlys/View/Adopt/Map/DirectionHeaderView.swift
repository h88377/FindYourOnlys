//
//  DirectionHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import UIKit
import MapKit

class DirectionHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var headerLabel: UILabel! {
        
        didSet {
            
            headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            
            headerLabel.textColor = .white
        }
    }
    
    @IBOutlet weak var informationLabel: UILabel! {
        
        didSet {
            
            informationLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            
            informationLabel.textColor = .white
        }
    }
    
    @IBOutlet weak var routeLabel: UILabel! {
        
        didSet {
            
            routeLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            routeLabel.textColor = .white
        }
    }
    
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
