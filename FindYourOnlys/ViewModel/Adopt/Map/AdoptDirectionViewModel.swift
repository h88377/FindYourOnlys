//
//  AdoptDirectionViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import Foundation
import MapKit

class AdoptDirectionViewModel {
    
    var directionViewModel = Box(
        DirectionViewModel(
            model: Direction(
                route: Route(origin: MKMapItem(), stops: []),
                mapRoutes: [], totalDistance: -1, totalTravelTime: -1
            )
        )
    )
}
