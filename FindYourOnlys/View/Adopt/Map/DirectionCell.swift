//
//  DirectionCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import UIKit
import MapKit

class DirectionCell: UITableViewCell {
    
    // MARK: - Properties

    @IBOutlet private weak var distanceLabel: UILabel! {
        
        didSet {
            
            distanceLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet private weak var descriptionLabel: UILabel! {
        
        didSet {
            
            descriptionLabel.textColor = .projectTextColor
        }
    }
    
    private let distanceFormatter = MKDistanceFormatter()
    
    // MARK: - Methods
    
    func configureCell(with direction: Direction, at indexPath: IndexPath) {
        
        let route = direction.mapRoutes[indexPath.section]
        let step = route.steps[indexPath.row + 1]
        
        distanceLabel.text = distanceFormatter.string(fromDistance: step.distance)
        
        descriptionLabel.text = "\(indexPath.row + 1): \(step.notice ?? step.instructions)"
    }
}
