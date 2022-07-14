//
//  CLPlacemark+Extension.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import MapKit

extension CLPlacemark {
    
    var abbreviation: String {
        
        if let name = self.name {
            
            return name
        }
        
        if let interestingPlace = areasOfInterest?.first {
            
            return interestingPlace
        }
        
        return [subThoroughfare, thoroughfare].compactMap { $0 }.joined(separator: " ")
    }
}
