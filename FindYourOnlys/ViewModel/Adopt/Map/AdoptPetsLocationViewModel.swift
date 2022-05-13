//
//  AdoptPetsLocationViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import MapKit

class AdoptPetsLocationViewModel {
    
    var isShelterMap: Bool = true
    
    var isSearch: Bool = false
    
    // Pet
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
    
    var getPetLocationHandler: (() -> Void)?
    
    func convertAddress() {
        
        guard
            !isShelterMap else { return }
        
        startLoadingHandler?()
            
        MapManager.shared.convertAddress(with: "\(petViewModel.value.pet.address)") { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let location):
                
                self.locationViewModel.value.location = location
                
                let pet = self.petViewModel.value.pet
                
                self.selectedMapAnnotation.value.mapAnnotation = MapAnnotation(
                    title: pet.kind, subtitle: pet.address,
                    location: pet.address,
                    coordinate: location.coordinate
                )
                
                self.getPetLocationHandler?()
                
                self.stopLoadingHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
        }
    }
    
    // Pets
    
//    var shelterViewModels = Box([ShelterViewModel]())
    
    var shelterViewModels: Box<[ShelterViewModel]?> = Box(nil)
    
    var mapAnnotationViewModels: Box<[MapAnnotationViewModel]?> = Box(nil)
    
    // Common
    
    var showAlertHandler: (() -> Void)?
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var routeViewModel = Box(RouteViewModel(model: Route(origin: MKMapItem(), stops: [MKMapItem]())))
    
    var mapRouteViewModel = Box(MapRouteViewModel(model: MKRoute()))
    
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
    
    var locationViewModel = Box(LocationViewModel(model: CLLocation()))
    
    var currentLocationViewModel = Box(LocationViewModel(model: CLLocation()))
    
    var showDirectionHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    func fetchShelter(with city: String) {
        
        guard
            isShelterMap else { return }
        
        if isSearch {

            mapAnnotationViewModels.value = nil
        }
        
        startLoadingHandler?()
        
        PetProvider.shared.fetchPet(
            with: AdoptFilterCondition(city: city, petKind: "", sex: "", color: "")) { [weak self] result in
            
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
                        
                        shelter = Shelter(
                            title: shelterName,
                            address: pet.address,
                            petCounts: [catPetCount, dogPetCount, otherPetCount]
                        )
                    }
                    
                    if shelter.title != "" {
                        
                        shelters.append(shelter)
                    }
                }
                
//                ShelterProvider.shared.setShelters(with: self.shelterViewModels, shelter: shelters)
                
                if shelters.count == 0 {
                    
                    self.mapAnnotationViewModels.value = []
                    
                    self.stopLoadingHandler?()
                    
                } else {
                    
                    ShelterProvider.shared.setShelters(with: self.shelterViewModels, shelter: shelters)
                    
                    self.appendMapAnnotationsInViewModels(with: shelters)
                    
                    self.stopLoadingHandler?()
                }
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
            
        }
    }

    private func appendMapAnnotationsInViewModels(with shelters: [Shelter]) {
        
        shelters.forEach { shelter in
            
            MapManager.shared.convertAddress(with: shelter.address) { [weak self] result in
                
                guard
                    let self = self else { return }
                
                switch result {
                    
                case .success(let location):
                    
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
                    
                case .failure(let error):
                    
                    self.errorViewModel.value = ErrorViewModel(model: error)
                    
                }
            }
        }
    }
    
    func calculateRoute() {
        
        guard
            selectedMapAnnotation.value.mapAnnotation.coordinate.longitude != CLLocationDegrees(0.0)
        
        else {
            
            showAlertHandler?()
            
            return
        }
        
        startLoadingHandler?()
        
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
                
                self.showDirectionHandler?()
                
                self.stopLoadingHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
                
                self.stopLoadingHandler?()
            }
        }
    }
}
