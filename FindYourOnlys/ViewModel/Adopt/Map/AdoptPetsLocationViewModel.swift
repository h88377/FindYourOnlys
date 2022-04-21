//
//  AdoptPetsLocationViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import MapKit

class AdoptPetsLocationViewModel {
    
    var isShelterMap: Bool = true
    
    //Pet
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
    
    var petMapAnnotation = Box(
        MapAnnotationViewModel(
            model: MapAnnotation(
                title: "",
                subtitle: "",
                location: "",
                coordinate: CLLocationCoordinate2D())
        )
    )
    
    var locationViewModel = Box(LocationViewModel(model: CLLocation()))
    
    var currentLocationViewModel = Box(LocationViewModel(model: CLLocation()))
    
    var getPetLocationHandler: (() -> Void)?
    
    func convertAddress() {
        
        guard
            !isShelterMap else { return }
            
        MapManager.shared.convertAddress(with: "\(petViewModel.value.pet.address)") { [weak self] location in
            
            self?.locationViewModel.value.location = location
            
            self?.getPetLocationHandler?()
        }
    }
    
    //Pets
    
    var shelterViewModels = Box([ShelterViewModel]())
    
    var errorViewModel: Box<ErrorViewModel>?
    
    var routeViewModel = Box(RouteViewModel(model: Route(origin: MKMapItem(), stops: [MKMapItem]())))
    
    var mapRouteViewModel = Box(MapRouteViewModel(model: MKRoute()))
    
//    var updateViewHandler: (() -> Void)?
    
    var getUserLocationHandler: (() -> Void)?
    
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
    
    var mapAnnotationViewModels = Box([MapAnnotationViewModel]())
    
    func fetchShelter(with city: String, mapView: MKMapView) {
        
        guard
            isShelterMap else { return }
        
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
                
                self.appendMapAnnotationsInViewModels(with: shelters)
              
            case .failure(let error):
                
                self.errorViewModel?.value = ErrorViewModel(model: error)
            }
            
        }
    }

    private func appendMapAnnotationsInViewModels(with shelters: [Shelter]) {

        shelters.forEach { shelter in
            
            MapManager.shared.convertAddress(with: shelter.address) { [weak self] location in
                
                guard
                    let self = self else { return }
                
                let petCounts = shelter.petCounts
                
                let mapAnnotation = MapAnnotation(
                    title: shelter.title,
                    subtitle: "\(petCounts[0].petKind): \(petCounts[0].count), \(petCounts[1].petKind): \(petCounts[1].count), \(petCounts[2].petKind): \(petCounts[2].count)" ,
                    location: shelter.address,
                    coordinate: CLLocationCoordinate2D(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                )
                MapManager.shared.appendMapAnnotation(in: self.mapAnnotationViewModels, annotation: mapAnnotation)
            }
        }
    }
    
    func calculateRoute() {
        
        guard
            isShelterMap else { return }
        
        MapManager.shared.calculateRoute(
            currentCoordinate: currentMapAnnotation.value.mapAnnotation.coordinate,
            stopCoordinate: selectedMapAnnotation.value.mapAnnotation.coordinate) { [weak self] result in
            
            guard
                let self = self else { return }
            switch result {
                
            case .success(let(route, mapRoute)):
                
                self.routeViewModel.value.route = route
                
                self.mapRouteViewModel.value.mapRoute = mapRoute
                
                self.getUserLocationHandler?()
                
//                self.updateViewHandler?()
                
            case .failure(let error):
                
                self.errorViewModel?.value = ErrorViewModel(model: error)
            }
        }
    }
    
    func calculateRouteNew() {
        
        guard
            !isShelterMap else { return }
        
        MapManager.shared.calculateRouteNew(
            currentLocation: currentLocationViewModel.value.location,
            stopLocation: locationViewModel.value.location) { [weak self] result in
            
            guard
                let self = self else { return }
                
            switch result {
                
            case .success(let(route, mapRoute)):
                
                self.getUserLocationHandler?()
                
                self.routeViewModel.value.route = route
                
                self.mapRouteViewModel.value.mapRoute = mapRoute
                
//                self.updateViewHandler?()
                
            case .failure(let error):
                
                self.errorViewModel?.value = ErrorViewModel(model: error)
            }
        }
    }
}
