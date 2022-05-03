//
//  DirectionCell.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import UIKit
import MapKit

class DirectionCell: UITableViewCell {

    @IBOutlet weak var distanceLabel: UILabel! {
        
        didSet {
            
            distanceLabel.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var descriptionLabel: UILabel! {
        
        didSet {
            
            descriptionLabel.textColor = .projectTextColor
        }
    }
    
    private let distanceFormatter = MKDistanceFormatter()
    
    func configureCell(with viewModel: DirectionViewModel, at indexPath: IndexPath) {
        
        let route = viewModel.direction.mapRoutes[indexPath.section]
        let step = route.steps[indexPath.row + 1]
        
        distanceLabel.text = distanceFormatter.string(
            fromDistance: step.distance
        )
        descriptionLabel.text = "\(indexPath.row + 1): \(step.notice ?? step.instructions)"
    }
}
