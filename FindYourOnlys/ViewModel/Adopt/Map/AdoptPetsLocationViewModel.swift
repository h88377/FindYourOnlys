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
    
    var shelterViewModels = Box([ShelterViewModel]())
    
    var errorViewModel: Box<ErrorViewModel>?
    
//    func addAnnotationsWithShelterName(in mapView: MKMapView, with viewModels: [PetViewModel]) {
//
//        MapManager.shared.addAnimationsWithShelterName(in: mapView, with: viewModels)
//    }
    
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
    
}
