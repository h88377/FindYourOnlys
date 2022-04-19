//
//  PetLocationViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import Foundation
import MapKit

class AdoptPetLocationViewModel {
    
    var petViewModel = Box(
        PetViewModel(
            model: Pet(
                id: 0, location: "", kind: "",
                sex: "", bodyType: "", color: "",
                age: "", sterilization: "", bacterin: "",
                foundPlace: "", status: "", remark: "",
                openDate: "", closedDate: "", updatedDate: "",
                createdDate: "", photoURLString: "", address: "",
                telephone: "", variety: ""
            )
        )
    )
    
    func convertAddress(completion: @escaping (CLLocation) -> Void) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString("\(petViewModel.value.pet.address)") { placemarks, error in
            
            guard
                let placemarks = placemarks,
                
                let location = placemarks.first?.location
                    
            else { return }
            
            completion(location)
        }
    }
    
//    func getInitialLocation(mapView: MKMapView) {
//        
//        convertAddress { location in
//            
//            let initialLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            
//            mapView.centerToLocation(initialLocation)
//        }
//        
//        
//        
//        mapView.centerToLocation(initialLocation)
//        
//    }
    
}
