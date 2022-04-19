//
//  Direction.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import MapKit

struct Direction {
    
    var route: Route
    
    var mapRoutes: [MKRoute]
    
    var totalDistance: CLLocationDistance
    
    var totalTravelTime: TimeInterval
}
