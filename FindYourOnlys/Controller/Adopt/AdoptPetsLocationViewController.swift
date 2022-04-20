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
    
    override var isHiddenNavigationBar: Bool { return true }
    
    override var isHiddenTabBar: Bool { return true }
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.mapAnnotations.bind { [weak self] mapAnnotationViewModels in
            
            let annotations = mapAnnotationViewModels.map { $0.mapAnnotation }
            
            self?.mapView.addAnnotations(annotations)
            
            self?.mapView.showAnnotations(annotations, animated: true)
        }
        
        viewModel.petViewModels.bind { _ in
            
            
        }
        
        
    }
    
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
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
                
                self.mapView.addAnnotation(currentAnnotation)
                
//                self.currentPlace = firstPlace
                
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error requesting location: \(error.localizedDescription)")
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
}
