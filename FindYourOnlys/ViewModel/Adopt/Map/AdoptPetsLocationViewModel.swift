//
//  AdoptPetsLocationViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import MapKit

class AdoptPetsLocationViewModel {
    
    var shelterViewModels = Box([ShelterViewModel]())
    
    var errorViewModel: Box<ErrorViewModel>?
    
    var routeViewModel = Box(RouteViewModel(model: Route(origin: MKMapItem(), stops: [MKMapItem]())))
    
    var mapRouteViewModel = Box(MapRouteViewModel(model: MKRoute()))
    
    var updateViewHandler: (() -> Void)?
    
    var currentMapAnnotation = Box(
        MapAnnotationViewModel(
            model: MapAnnotation(
                title: "",
                subtitle: "",
                location: "",
                coordinate: CLLocationCoordinate2D())
        )
    )
    
    var selectedMapAnnotation = Box(
        MapAnnotationViewModel(
            model: MapAnnotation(
                title: "",
                subtitle: "",
                location: "",
                coordinate: CLLocationCoordinate2D())
        )
    )
    
    func fetchShelter(with city: String, mapView: MKMapView) {
        
        PetProvider.shared.fetchPet(with: city) { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let pets):
                
                // Get shelter with specific address
                let shelterNames = ShelterName.allCases
                    .map { $0.rawValue }
                    .filter { $0[...2] == city }
                
                var shelters = [Shelter]()
                
                for shelterName in shelterNames {
                    
                    var shelter = Shelter(title: "", address: "", petCounts: [])
                    
                    var catPetCount = PetCount(petKind: "貓", count: 0)
                    
                    var dogPetCount = PetCount(petKind: "狗", count: 0)
                    
                    var otherPetCount = PetCount(petKind: "其他", count: 0)
                    
                    for pet in pets where pet.shelterName == shelterName {
                        
                        switch pet.kind {
                            
                        case "貓":
                            catPetCount.count += 1
                            
                        case "狗":
                            dogPetCount.count += 1
                            
                        default:
                            otherPetCount.count += 1
                        }
                        
                        shelter = Shelter(title: shelterName, address: pet.address, petCounts: [catPetCount, dogPetCount, otherPetCount])
                    }
                    if shelter.title != "" {
                        
                        shelters.append(shelter)
                    }
                }
                
                ShelterProvider.shared.setShelters(with: self.shelterViewModels, shelter: shelters)
                self.addAnnotations(in: mapView, with: self.shelterViewModels.value)
                
            case .failure(let error):
                
                self.errorViewModel?.value = ErrorViewModel(model: error)
            }
            
        }
    }
    
    func addAnnotations(in mapView: MKMapView, with viewModels: [ShelterViewModel]) {
        
        MapManager.shared.addAnimationsWithShelter(in: mapView, with: viewModels)
    }
    
    func calculateRoute() {
        
        MapManager.shared.calculateRoute(
            currentCoordinate: currentMapAnnotation.value.mapAnnotation.coordinate,
            stopCoordinate: selectedMapAnnotation.value.mapAnnotation.coordinate) { [weak self] result in
            
            guard
                let self = self else { return }
            switch result {
                
            case .success(let(route, mapRoute)):
                
                self.routeViewModel.value.route = route
                
                self.mapRouteViewModel.value.mapRoute = mapRoute
                
                self.updateViewHandler?()
                
            case .failure(let error):
                
                self.errorViewModel?.value = ErrorViewModel(model: error)
            }
        }
    }
    private func updateView(mapView: MKMapView, with mapRoute: MKRoute) {
        
        
        
        let padding: CGFloat = 8
        
        mapView.addOverlay(mapRoute.polyline)
        
        mapView.setVisibleMapRect(
            mapView.visibleMapRect.union(mapRoute.polyline.boundingMapRect),
            edgePadding: UIEdgeInsets(
                top: 0,
                left: padding,
                bottom: padding,
                right: padding
            ),
            animated: true
        )
    }
}
