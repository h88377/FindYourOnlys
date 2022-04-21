//
//  AdoptPetsLocationViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import UIKit
import MapKit

class AdoptPetsLocationViewController: BaseViewController {
    
    let viewModel = AdoptPetsLocationViewModel()
    
    private let locationManager = CLLocationManager()
    
    override var isHiddenNavigationBar: Bool { return true }
    
    override var isHiddenTabBar: Bool { return true }
    
    @IBOutlet weak var mapView: MKMapView! {
        
        didSet {
            
            mapView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Pet
        viewModel.convertAddress()
        
        viewModel.getUserLocationHandler = { [weak self] in

            guard
                let self = self else { return }

            self.mapView.centerToLocation(self.viewModel.currentLocationViewModel.value.location)

            self.mapView.addAnnotation(self.viewModel.currentMapAnnotation.value.mapAnnotation)
            
            self.updateView(with: self.viewModel.mapRouteViewModel.value.mapRoute)
        }
        
        
        //Pets
        attemptLocationAccess()
        
        viewModel.mapAnnotationViewModels.bind { [weak self] _ in
            
            guard
                let self = self else { return }
            
            let mapAnnotations = self.viewModel.mapAnnotationViewModels.value.map { $0.mapAnnotation }
            
            self.mapView.addAnnotations(mapAnnotations)
            
            self.mapView.showAnnotations(mapAnnotations, animated: true)
        }
    }
    
    //Pet
    func addAnnotation() {

        let pet = viewModel.petViewModel.value.pet
        
        let location = viewModel.locationViewModel.value.location
        
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
    
    
    // Pets
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        viewModel.calculateRoute()
        
//        viewModel.calculateRouteNew()
        
//        mapView.addAnnotation(viewModel.currentMapAnnotation.value.mapAnnotation)
        
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
    
    private func updateView(with mapRoute: MKRoute) {
        
        if
            mapView.overlays.count != 0 {
            
            mapView.removeOverlay(mapView.overlays[0])
        }
        
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
        
        mapView.showAnnotations([viewModel.currentMapAnnotation.value.mapAnnotation, viewModel.selectedMapAnnotation.value.mapAnnotation], animated: true)
        
        //        totalDistance += mapRoute.distance
        //
        //        totalTravelTime += mapRoute.expectedTravelTime
        //
        //        mapRoutes.append(mapRoute)
        //
        //        adoptDirectionVC?.viewModel.directionViewModel.value.direction.mapRoutes = mapRoutes
        //
        //        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalDistance = totalDistance
        //
        //        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalTravelTime = totalTravelTime
        
    }
    
}

// MARK: - CLLocationManagerDelegate
extension AdoptPetsLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
            
            guard
                status == .authorizedWhenInUse
                    
            else {
                
                return
            }
            manager.requestLocation()
        }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
            
            guard
                let firstLocation = locations.first
                    
            else {
                
                return
            }
            
            CLGeocoder().reverseGeocodeLocation(firstLocation) { [weak self] places, _ in
                
                guard
                    let firstPlace = places?.first,
                    let self = self
                        
                else { return }
                
                let currentAnnotation = MapAnnotation(
                    title: "現在位置", subtitle: "\(firstPlace.abbreviation)", location: "\(firstPlace)",
                    coordinate: CLLocationCoordinate2D(latitude: firstLocation.coordinate.latitude, longitude: firstLocation.coordinate.longitude)
                )
                self.viewModel.currentMapAnnotation.value.mapAnnotation = currentAnnotation
                
                self.viewModel.currentLocationViewModel.value.location = firstLocation
                
                // Mock location because Taipei don't have any shelter.
                
                self.viewModel.fetchShelter(with: "新北市", mapView: self.mapView)
                
//                self.viewModel.fetchShelter(with: firstPlace.subAdministrativeArea ?? "新北市", mapView: self.mapView)
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("=====Error requesting location: \(error.localizedDescription)")
    }
    
}



// MARK: - MKMapViewDelegate

extension AdoptPetsLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = .systemBlue
        renderer.lineWidth = 3
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard
            let selectedMapAnnotation = view.annotation as? MapAnnotation
                
        else { return }
        
        viewModel.selectedMapAnnotation.value.mapAnnotation = selectedMapAnnotation
        
    }
}


// MARK: - UIViewControllerTransitioningDelegate
extension AdoptPetsLocationViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}
