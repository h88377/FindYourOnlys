//
//  LocationViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/21.
//

import Foundation
import CoreLocation

class LocationViewModel {
    
    var location: CLLocation
    
    init(model: CLLocation) {
        
        self.location = model
    }
}
