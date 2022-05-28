//
//  Placemark.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import Foundation
import CoreLocation
import MapKit

class MapAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    
    let subtitle: String?
    
    let location: String
    
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, subtitle: String, location: String, coordinate: CLLocationCoordinate2D) {
        
        self.title = title
        
        self.subtitle = subtitle
        
        self.location = location
        
        self.coordinate = coordinate
    }
    
    override init() {
        
        self.title = ""
        
        self.subtitle = ""
        
        self.location = ""
        
        self.coordinate = CLLocationCoordinate2D()
    }
}
