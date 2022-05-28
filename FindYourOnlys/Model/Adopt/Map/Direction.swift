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
    
    init() {
        
        self.route = Route(origin: MKMapItem(), stops: [])
        
        self.mapRoutes = []
        
        self.totalDistance = -1
        
        self.totalTravelTime = -1
    }
    
    init(route: Route, mapRoutes: [MKRoute], totalDistance: CLLocationDistance, totalTravelTime: TimeInterval) {
        
        self.route = route
        
        self.mapRoutes = mapRoutes
        
        self.totalDistance = totalDistance
        
        self.totalTravelTime = totalTravelTime
    }
}
