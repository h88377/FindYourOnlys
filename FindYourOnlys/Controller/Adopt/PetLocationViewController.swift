//
//  PetLocationViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import UIKit
import MapKit
import AVFAudio

class PetLocationViewController: BaseViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let viewModel = PetLocationViewModel()
    
    private let locationManager = CLLocationManager()
    
    //    var placemark: Placemark {
    //
    //
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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
    
    func addAnnotation(with location: CLLocation) {
        
        
        
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        attemptLocationAccess()
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

// MARK: - CLLocationManagerDelegate
extension PetLocationViewController: CLLocationManagerDelegate {
    
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
