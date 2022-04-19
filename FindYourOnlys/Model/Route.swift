//
//  Route.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import MapKit

struct Route {
    
    let origin: MKMapItem
    
    let stops: [MKMapItem]
    
    var annotations: [MKAnnotation] {
        
        var annotations: [MKAnnotation] = []
        
        annotations.append(
            
            RouteAnnotation(item: origin)
        )
        
        annotations.append(contentsOf: stops.map { stop in
            
            return RouteAnnotation(item: stop)
        })
        
        return annotations
    }
    
    var label: String {
        
        if let name = stops.first?.name, stops.count == 1 {
            
            return "Directions to \(name)"
            
        } else {
            
            let stopNames = stops.compactMap { stop in
                
                return stop.name
            }
            
            let namesString = stopNames.joined(separator: " and ")
            
            return "Directions between \(namesString)"
        }
    }
}
