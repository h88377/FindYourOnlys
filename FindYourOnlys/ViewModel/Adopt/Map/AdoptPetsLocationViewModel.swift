//
//  AdoptPetsLocationViewModel.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import MapKit

enum ShelterName: String, CaseIterable {
    
    case keelung = "基隆市寵物銀行"
    
    case taipei = "臺北市動物之家"
    
    case banchiao = "新北市板橋區公立動物之家"
    
    case shindian = "新北市新店區公立動物之家"
    
    case chunhia = "新北市中和區公立動物之家"
    
    case tamshuia = "新北市淡水區公立動物之家"
    
    case taoyuan = "桃園市動物保護教育園區"
    
    case hsinchuCountry = "新竹縣公立動物收容所"
    
    case hsinchu = "新竹市動物保護教育園區"
    
    case newtaipei = "新北市政府動物保護防疫處"
    
    case miaoliCountry = "苗栗縣生態保育教育中心(動物收容所)"
    
    case taichung = "臺中市動物之家南屯園區"
    
    case hiuali = "臺中市動物之家后里園區"
    
    case changhuaCountry = "彰化縣流浪狗中途之家"
    
    case nantou = "南投縣公立動物收容所"
    
    case yunlin = "雲林縣流浪動物收容所"
    
    case chiayiCountry = "嘉義縣流浪犬中途之家"
    
    case chiayi = "嘉義市動物保護教育園區"
    
    case tainan = "臺南市動物之家灣裡站"
    
    case tainanshanhua = "臺南市動物之家善化站"
    
    case kaohsiung = "高雄市壽山動物保護教育園區"
    
    case ianchao = "高雄市燕巢動物保護關愛園區"
    
    case pingtungCountry = "屏東縣公立犬貓中途之家"
    
    case yilanCountry = "宜蘭縣流浪動物中途之家"
    
    case hualianCountry = "花蓮縣狗貓躍動園區"
    
    case taitungCountry = "臺東縣動物收容中心"
    
    case penghu = "澎湖縣流浪動物收容中心"
    
    case kinmen = "金門縣動物收容中心"
    
    case lienchiang = "連江縣流浪犬收容中心"
    
    case ruifang = "新北市瑞芳區公立動物之家"
    
    case wuku = "新北市五股區公立動物之家"
    
    case bali = "新北市八里區公立動物之家"
    
    case shanchi = "新北市三芝區公立動物之家"
}

class AdoptPetsLocationViewModel {
    
    // MARK: - Properties
    
    var mapAnnotationViewModels: Box<[MapAnnotationViewModel]?> = Box(nil)
    
    var errorViewModel: Box<ErrorViewModel?> = Box(nil)
    
    var isShelterMap: Bool = true
    
    var isSearch: Bool = false
    
    var pet: Pet?
    
    var shelters: [Shelter]?
    
    var route: Route?
    
    var mapRoute: MKRoute?
    
    var currentMapAnnotation: MapAnnotation?
    
    var selectedMapAnnotation: MapAnnotation?
    
    var petLocation: CLLocation?
    
    var currentLocation: CLLocation?
    
    var getUserLocationHandler: (() -> Void)?
    
    var getPetLocationHandler: (() -> Void)?
    
    var showAlertHandler: (() -> Void)?
    
    var showDirectionHandler: (() -> Void)?
    
    var stopLoadingHandler: (() -> Void)?
    
    var startLoadingHandler: (() -> Void)?
    
    // MARK: - Methods
    
    func convertAddress() {
        
        guard
            !isShelterMap,
            let pet = pet
                
        else { return }
        
        startLoadingHandler?()
            
        MapManager.shared.convertAddress(with: "\(pet.address)") { [weak self] result in
            
            guard
                let self = self else { return }
            
            switch result {
                
            case .success(let location):
                
                self.petLocation = location
                
                self.selectedMapAnnotation = MapAnnotation(
                    title: pet.kind, subtitle: pet.address,
                    location: pet.address,
                    coordinate: location.coordinate
                )
                
                self.getPetLocationHandler?()
                
            case .failure(let error):
                
                self.errorViewModel.value = ErrorViewModel(model: error)
            }
            
            self.stopLoadingHandler?()
        }
    }
    
    func fetchShelter(with city: String) {
        
        guard
            isShelterMap else { return }
        
        if isSearch {
            
            mapAnnotationViewModels.value = nil
        }
        
        startLoadingHandler?()
        
        PetProvider.shared.fetchPet(
            with: AdoptFilterCondition()) { [weak self] result in
                
                guard
                    let self = self else { return }
                
                switch result {
                    
                case .success(let pets):
                    
                    let shelters = self.convertShelters(from: pets, city: city)
                    
                    if shelters.isEmpty {
                        
                        self.mapAnnotationViewModels.value = []
                        
                    } else {
                        
                        self.shelters = shelters
                        
                        self.appendMapAnnotationsInViewModels(with: shelters)
                    }
                    
                case .failure(let error):
                    
                    self.errorViewModel.value = ErrorViewModel(model: error)
                }
                
                self.stopLoadingHandler?()
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
                        subtitle: "\(petCounts[0].petKind): \(petCounts[0].count), " +
                        "\(petCounts[1].petKind): \(petCounts[1].count), " +
                        "\(petCounts[2].petKind): \(petCounts[2].count)",
                        location: shelter.address,
                        coordinate: CLLocationCoordinate2D(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude
                        )
                    )
                    
                    self.appendMapAnnotation(annotation: mapAnnotation)
                    
                case .failure(let error):
                    
                    self.errorViewModel.value = ErrorViewModel(model: error)
                    
                }
            }
        }
    }
    
    func calculateRoute() {
        
        guard
            selectedMapAnnotation?.coordinate.longitude != CLLocationDegrees(0.0),
            let currentCoordinate = currentMapAnnotation?.coordinate,
            let stopCoordinate = selectedMapAnnotation?.coordinate
        
        else {
            
            showAlertHandler?()
            
            return
        }
        
        startLoadingHandler?()
        
        MapManager.shared.calculateRoute(
            currentCoordinate: currentCoordinate,
            stopCoordinate: stopCoordinate) { [weak self] result in
                
                guard
                    let self = self else { return }
                
                switch result {
                    
                case .success(let(route, mapRoute)):
                    
                    self.route = route
                    
                    self.mapRoute = mapRoute
                    
                    self.getUserLocationHandler?()
                    
                    self.showDirectionHandler?()
                    
                case .failure(let error):
                    
                    self.errorViewModel.value = ErrorViewModel(model: error)
                }
                
                self.stopLoadingHandler?()
            }
    }
    
    private func convertShelters(from pets: [Pet], city: String) -> [Shelter] {
        
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
        
        return shelters
    }
    
    private func appendMapAnnotation(annotation: MapAnnotation) {
        
        if
            mapAnnotationViewModels.value == nil {
            
            mapAnnotationViewModels.value = [MapAnnotationViewModel(model: annotation)]
            
        } else {
            
            mapAnnotationViewModels.value?.append(MapAnnotationViewModel(model: annotation))
        }
    }
}
