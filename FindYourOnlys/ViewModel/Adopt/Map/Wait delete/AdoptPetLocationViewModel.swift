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
                telephone: "", variety: "", shelterName: ""
            )
        )
    )
    
    func convertAddress(completion: @escaping (CLLocation) -> Void) {
        
        MapManager.shared.convertAddress(with: "\(petViewModel.value.pet.address)") { location in
            
            completion(location)
        }
    }
    
    func addAnnotation(in mapView: MKMapView, with viewModel: PetViewModel) {
        
        MapManager.shared.addAnimationWithPetKind(in: mapView, with: viewModel)
    }
    
}
