//
//  PetLocationViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import UIKit
import MapKit
import AVFAudio

class AdoptPetLocationViewController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var navigateButton: UIButton!
    
    let viewModel = AdoptPetLocationViewModel()
    
    private let locationManager = CLLocationManager()
    
    private var currentRegion: MKCoordinateRegion?
    
    private var currentPlace: CLPlacemark?
    
    private var stopPlace: CLLocation?
    
    private var mapRoutes: [MKRoute] = []
    
    private var route: Route?
    
//    private var groupedRoutes: [(startItem: MKMapItem, endItem: MKMapItem)] = []
    
    private var totalDistance: CLLocationDistance = 0
    
    private var totalTravelTime: TimeInterval = 0
    
    private let distanceFormatter = MKDistanceFormatter()
    
    //    var placemark: Placemark {
    //
    //
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attemptLocationAccess()
        
        mapView.delegate = self
        
        viewModel.convertAddress { [weak self] location in
            
            guard
                let self = self else { return }
            
            self.mapView.centerToLocation(location)
            
            let pet = self.viewModel.petViewModel.value.pet
            
            let mapAnnotation = MapAnnotation(
                title: pet.kind, subtitle: pet.address, location: pet.location,
                coordinate: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            )
            
            self.mapView.addAnnotation(mapAnnotation)
            
            self.stopPlace = location
        }
        
    }
    
    private func attemptLocationAccess() {
        
        guard
            CLLocationManager.locationServicesEnabled()
                
        else {
            
            return
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        locationManager.delegate = self
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            
            locationManager.requestWhenInUseAuthorization()
            
        } else {
            
            locationManager.requestLocation()
        }
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        navigateButton.isEnabled = false
        
        let segment: RouteBuilder.Segment?
        
        if let currentLocation = currentPlace?.location {
            
            segment = .location(currentLocation)
            
        } else {
            
            segment = nil
        }
        
        guard
            let stopPlace = stopPlace else { return }
        
        let stopSegments: [RouteBuilder.Segment] = [.location(stopPlace)]
        
        guard
            let originSegment = segment,
            !stopSegments.isEmpty
                
        else {
            
            navigateButton.isEnabled = true
            return
        }
        
        RouteBuilder.buildRoute(
            origin: originSegment,
            stops: stopSegments,
            within: currentRegion
        ) { [weak self] result in
            
            self?.navigateButton.isEnabled = true
            
            switch result {
            case .success(let route):
                
                self?.route = route
                
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

                  self?.updateView(with: mapRoute)
                }
                
                
//                let storyboard = UIStoryboard.adopt
//
//                guard
//                    let adoptPetDirectionVC = storyboard.instantiateViewController(withIdentifier: AdoptDirectionViewController.identifier) as? AdoptDirectionViewController
//
//                else { return }
//
//                adoptPetDirectionVC.route = route
//
//                adoptPetDirectionVC.modalPresentationStyle = .custom
//
//                self.present(adoptPetDirectionVC, animated: true)
                
            case .failure(let error):
                
                let errorMessage: String
                
                switch error {
                case .invalidSegment(let reason):
                    
                    errorMessage = "There was an error with: \(reason)."
                }
                
                print(errorMessage)
            }
        }
    }
    
    private func updateView(with mapRoute: MKRoute) {
        
      let padding: CGFloat = 8
        
      mapView.addOverlay(mapRoute.polyline)
        
      mapView.setVisibleMapRect(
        
        mapView.visibleMapRect.union(
            
          mapRoute.polyline.boundingMapRect
        ),
        edgePadding: UIEdgeInsets(
          top: 0,
          left: padding,
          bottom: padding,
          right: padding
        ),
        animated: true
      )

      totalDistance += mapRoute.distance
      totalTravelTime += mapRoute.expectedTravelTime

//      let informationComponents = [
//        totalTravelTime.formatted,
//        "• \(distanceFormatter.string(fromDistance: totalDistance))"
//      ]
//      informationLabel.text = informationComponents.joined(separator: " ")

      mapRoutes.append(mapRoute)
    }
    
    
}


// MARK: - CLLocationManagerDelegate
extension AdoptPetLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {
        // 1
        guard
            status == .authorizedWhenInUse
                
        else {
            
            return
        }
        manager.requestLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        
        guard
            let firstLocation = locations.first
                
        else {
            
            return
        }
        
        // TODO: Configure MKLocalSearchCompleter here...
        
        // 2
        CLGeocoder().reverseGeocodeLocation(firstLocation) { [weak self] places, _ in
            // 3
            guard
                let firstPlace = places?.first,
                let self = self
                    
            else { return }
            
            let pet = self.viewModel.petViewModel.value.pet
            
            let currentAnnotation = MapAnnotation(
                title: "現在位置", subtitle: "\(firstPlace.abbreviation)", location: "\(firstPlace)",
                coordinate: CLLocationCoordinate2D(latitude: firstLocation.coordinate.latitude, longitude: firstLocation.coordinate.longitude)
            )
            
            self.mapView.addAnnotation(currentAnnotation)
            
            self.currentPlace = firstPlace
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error requesting location: \(error.localizedDescription)")
    }
    
}

extension CLPlacemark {
    var abbreviation: String {
        if let name = self.name {
            return name
        }
        
        if let interestingPlace = areasOfInterest?.first {
            return interestingPlace
        }
        
        return [subThoroughfare, thoroughfare].compactMap { $0 }.joined(separator: " ")
    }
}



private extension MKMapView {
    func centerToLocation(
        _ location: CLLocation,
        regionRadius: CLLocationDistance = 50000
    ) {
        let coordinateRegion = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: regionRadius,
            longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension AdoptPetLocationViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    let renderer = MKPolylineRenderer(overlay: overlay)

    renderer.strokeColor = .systemBlue
    renderer.lineWidth = 3

    return renderer
  }
}
