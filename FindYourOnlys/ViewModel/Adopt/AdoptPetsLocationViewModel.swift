//
//  AdoptPetsLocationViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import MapKit

class AdoptPetsLocationViewModel {
    
    var petViewModels = Box([PetViewModel]())
    
    var mapAnnotations = Box([MapAnnotationViewModel]())
    
    func addAnnotationsToMapView(mapView: inout MKMapView) {
        
        
        
    }
    
    func convertAddress() {
        
        let addresses = petViewModels.value.map { $0.pet.address }
        
        
        
    }
}
