//
//  DirectionHeaderView.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import UIKit
import MapKit

class DirectionHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Properties
    
    @IBOutlet private weak var baseView: UIView! {
        
        didSet {
            
            baseView.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var headerLabel: UILabel! {
        
        didSet {
            
            headerLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            
            headerLabel.textColor = .white
        }
    }
    
    @IBOutlet private weak var informationLabel: UILabel! {
        
        didSet {
            
            informationLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            
            informationLabel.textColor = .white
        }
    }
    
    @IBOutlet private weak var routeLabel: UILabel! {
        
        didSet {
            
            routeLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            
            routeLabel.textColor = .white
        }
    }
    
    private let distanceFormatter = MKDistanceFormatter()
    
    // MARK: - Methods
    
    func configureView(with direction: Direction, route: MKRoute) {
        
        headerLabel.text = direction.route.label
        
        let informationComponents = [
            direction.totalTravelTime.formatted,
            "• \(distanceFormatter.string(fromDistance: direction.totalDistance))"]
        
        self.informationLabel.text = informationComponents.joined(separator: " ")
        
        routeLabel.text = route.name
    }
}
