//
//  MapManager.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import MapKit

enum MapError: Error {
    
    case convertAddressError
    
    case calculateRouteError
    
    case unexpectedError
    
    var errorMessage: String {
        
        switch self {
            
        case .convertAddressError:
            
            return "讀取地址失敗，請稍後再試"
            
        case .calculateRouteError:
            
            return "計算導航路徑失敗，請稍後再試"
            
        case .unexpectedError:
            
            return "發生預期外的異常，請稍後再試"
        }
    }
}

class MapManager {
    
    static let shared = MapManager()
    
    func convertAddress(with address: String, completion: @escaping (Result<CLLocation, Error>) -> Void) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { placemarks, _ in
            
            guard
                let placemarks = placemarks,
                let location = placemarks.first?.location
                    
            else {
                
                completion(.failure(MapError.convertAddressError))
                
                return
                
            }
            
            completion(.success(location))
        }
    }
    
    func calculateRoute(
        currentCoordinate: CLLocationCoordinate2D,
        stopCoordinate: CLLocationCoordinate2D,
        completion: @escaping (Result<(route: Route, mapRoute: MKRoute), Error>
        ) -> Void) {
        
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
                
                directions.calculate { response, _ in
                    
                    guard
                        let mapRoute = response?.routes.first
                            
                    else {
                        
                        completion(.failure(MapError.calculateRouteError))
                        
                        return
                    }
                    
                    completion(.success((route, mapRoute)))
                }
                
            case .failure:
                
                completion(.failure(MapError.calculateRouteError))
            }
        }
        
    }
    
    // MARK: - Convert functions
    
    func appendMapAnnotation(in viewModels: Box<[MapAnnotationViewModel]?>, annotation: MapAnnotation) {
        
        if
            viewModels.value == nil { viewModels.value = [MapAnnotationViewModel(model: annotation)] } else {
            
            viewModels.value?.append(MapAnnotationViewModel(model: annotation))
        }
    }
}
