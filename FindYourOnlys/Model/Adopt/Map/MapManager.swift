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
    
    // PetsLocation
    func addAnimationWithPetKind(in mapView: MKMapView, with viewModel: PetViewModel) {
        
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
    
    // PetsLocation
//    func addAnimationWithPetKind(with viewModel: PetViewModel, compl) {
//        
//        let pet = viewModel.pet
//        
//        convertAddress(with: pet.address) { location in
//            
//            let mapAnnotation = MapAnnotation(
//                title: pet.kind,
//                subtitle: pet.address,
//                location: pet.location,
//                coordinate: CLLocationCoordinate2D(
//                    latitude: location.coordinate.latitude,
//                    longitude: location.coordinate.longitude
//                )
//            )
//            
//            mapView.addAnnotation(mapAnnotation)
//        }
//    }
    
    
//    func addAnimationsWithShelter(in mapView: MKMapView, with viewModels: [ShelterViewModel]) {
//
//        let shelters = viewModels.map { $0.shelter }
//
//        shelters.forEach { shelter in
//
//            convertAddress(with: shelter.address) { location in
//
//                let petCounts = shelter.petCounts
//                
//                let mapAnnotation = MapAnnotation(
//                    title: shelter.title,
//                    subtitle: "\(petCounts[0].petKind): \(petCounts[0].count), \(petCounts[1].petKind): \(petCounts[1].count), \(petCounts[2].petKind): \(petCounts[2].count)" ,
//                    location: shelter.address,
//                    coordinate: CLLocationCoordinate2D(
//                        latitude: location.coordinate.latitude,
//                        longitude: location.coordinate.longitude
//                    )
//                )
//                mapView.addAnnotation(mapAnnotation)
//            }
//        }
//        DispatchQueue.main.async {
//            
//            mapView.showAnnotations(mapView.annotations, animated: true)
//        }
//
//    }
    
    func calculateRouteNew(currentLocation: CLLocation, stopLocation: CLLocation, completion: @escaping (Result<(route: Route, mapRoute: MKRoute), Error>) -> Void) {
            
        let currentSegment: RouteBuilder.Segment = .location(currentLocation)
        
        let stopSegments: [RouteBuilder.Segment] = [.location(stopLocation)]
        
        RouteBuilder.buildRoute(
            origin: currentSegment,
            stops: stopSegments, within: nil
        ) { result in
            
            switch result {
            case .success(let route):
                
                guard
                    let firstStop = route.stops.first else { return }
                
                let group: (startItem: MKMapItem, endItem: MKMapItem) = (route.origin, firstStop)
                
                let request = MKDirections.Request()
                
                request.source = group.startItem
                
                request.destination = group.endItem
                
                let directions = MKDirections(request: request)
                
                directions.calculate { response, error in
                    
                    guard
                        let mapRoute = response?.routes.first
                            
                    else {
                        
                        print(error)
                        
                        return
                    }
                    
                    completion(.success((route, mapRoute)))
                }
                
            case .failure(let error):
                
                let errorMessage: String
                
                switch error {
                    
                case .invalidSegment(let reason):
                    
                    errorMessage = "There was an error with: \(reason)."
                }
                
                completion(.failure(error))
            }
        }
        
    }
    
    func calculateRoute(currentCoordinate: CLLocationCoordinate2D, stopCoordinate: CLLocationCoordinate2D, completion: @escaping (Result<(route: Route, mapRoute: MKRoute), Error>) -> Void) {
        
        let currentLatitude = currentCoordinate.latitude
        
        let currentLongitude = currentCoordinate.longitude
        
        let currentLocation = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
            
        let currentSegment: RouteBuilder.Segment = .location(currentLocation)
        
        let stopLatitude = stopCoordinate.latitude
        
        let stopLongitude = stopCoordinate.longitude
        
        let stopLocation = CLLocation(latitude: stopLatitude, longitude: stopLongitude)
        
        let stopSegments: [RouteBuilder.Segment] = [.location(stopLocation)]
        
        RouteBuilder.buildRoute(
            origin: currentSegment,
            stops: stopSegments, within: nil
        ) { result in
            
            switch result {
            case .success(let route):
                
                guard
                    let firstStop = route.stops.first else { return }
                
                let group: (startItem: MKMapItem, endItem: MKMapItem) = (route.origin, firstStop)
                
                let request = MKDirections.Request()
                
                request.source = group.startItem
                
                request.destination = group.endItem
                
                let directions = MKDirections(request: request)
                
                directions.calculate { response, error in
                    
                    guard
                        let mapRoute = response?.routes.first
                            
                    else {
                        
                        print(error)
                        
                        return
                    }
                    
                    completion(.success((route, mapRoute)))
                }
                
            case .failure(let error):
                
                let errorMessage: String
                
                switch error {
                    
                case .invalidSegment(let reason):
                    
                    errorMessage = "There was an error with: \(reason)."
                }
                
                completion(.failure(error))
            }
        }
        
    }
    
    // MARK: - Convert functions

//    private func convertMapAnnotationsToViewModels(from annotations: [MapAnnotation]) -> [MapAnnotationViewModel] {
//        
//        var viewModels = [MapAnnotationViewModel]()
//        
//        for annotation in annotations {
//            
//            let viewModel = MapAnnotationViewModel(model: annotation)
//            
//            viewModels.append(viewModel)
//        }
//        return viewModels
//    }

    func appendMapAnnotation(in viewModels: Box<[MapAnnotationViewModel]>, annotation: MapAnnotation) {
        
        viewModels.value.append(MapAnnotationViewModel(model: annotation))
    }
    
//    func setMapAnnotations(with viewModels: Box<[MapAnnotationViewModel]>, annotations: [MapAnnotation]) {
//
//        viewModels.value = convertMapAnnotationsToViewModels(from: annotations)
//    }
    
//    func addAnimationsWithPetKind(in mapView: MKMapView, with viewModels: [PetViewModel]) {
//        
//        let pets = viewModels.map { $0.pet }
//        
//        pets.forEach { pet in
//            
//            convertAddress(with: pet.address) { location in
//                
//                let mapAnnotation = MapAnnotation(
//                    title: pet.kind,
//                    subtitle: pet.address,
//                    location: pet.location,
//                    coordinate: CLLocationCoordinate2D(
//                        latitude: location.coordinate.latitude,
//                        longitude: location.coordinate.longitude
//                    )
//                )
//                mapView.addAnnotation(mapAnnotation)
//            }
//        }
//    }
    
//    func addAnimationsWithShelterName(in mapView: MKMapView, with viewModels: [PetViewModel]) {
//
//        let pets = viewModels.map { $0.pet }
//
//        var mapAnnotations = [MapAnnotation]()
//
//        pets.forEach { pet in
//
//            convertAddress(with: pet.address) { location in
//
//                let mapAnnotation = MapAnnotation(
//                    title: pet.shelterName,
//                    subtitle: pet.address,
//                    location: pet.location,
//                    coordinate: CLLocationCoordinate2D(
//                        latitude: location.coordinate.latitude,
//                        longitude: location.coordinate.longitude
//                    )
//                )
//                mapAnnotations.append(mapAnnotation)
//            }
//        }
//        let unique = Array(Set(mapAnnotations))
//
//        mapView.addAnnotations(mapAnnotations)
//    }
//
//    func addAnimationsWithShelterName2(in mapView: MKMapView, with viewModels: [PetViewModel]) {
//
//        let shelter = [Shelter]()
//
//        let pets = viewModels.map { $0.pet }
//
//        pets.forEach { pet in
//            pet.
//        }
//    }
}
