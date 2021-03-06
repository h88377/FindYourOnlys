//
//  RouteAnnotation.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import MapKit

class RouteAnnotation: NSObject {
    
    private let item: MKMapItem
    
    init(item: MKMapItem) {
        
        self.item = item
        
        super.init()
    }
}

// MARK: - MKAnnotation

extension RouteAnnotation: MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        
        return item.placemark.coordinate
    }
    
    var title: String? {
        
        return item.name
    }
}
