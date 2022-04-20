//
//  MapManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import MapKit

class MapManager {
    
    static let shared = MapManager()
    
    func convertAddress(with address: String, completion: @escaping (CLLocation) -> Void) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { placemarks, error in
            
            guard
                let placemarks = placemarks,
                
                let location = placemarks.first?.location
                    
            else { return }
            
            completion(location)
        }
    }
    
    func addAnimation(in mapView: MKMapView, with viewModel: PetViewModel) {
        
        let pet = viewModel.pet
        
        convertAddress(with: pet.address) { location in
            
            let mapAnnotation = MapAnnotation(
                title: pet.kind,
                subtitle: pet.address,
                location: pet.location,
                coordinate: CLLocationCoordinate2D(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            )
            
            mapView.addAnnotation(mapAnnotation)
        }
    }
    
    func addAnimations(in mapView: MKMapView, with viewModels: [PetViewModel]) {
        
        let pets = viewModels.map { $0.pet }
        
        pets.forEach { pet in
            
            convertAddress(with: pet.address) { location in
                
                let mapAnnotation = MapAnnotation(
                    title: pet.kind,
                    subtitle: pet.address,
                    location: pet.location,
                    coordinate: CLLocationCoordinate2D(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                )
                mapView.addAnnotation(mapAnnotation)
            }
        }
    }
}
