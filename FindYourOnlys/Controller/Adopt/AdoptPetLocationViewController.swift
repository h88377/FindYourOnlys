//
//  PetLocationViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/19.
//

import UIKit
import MapKit

class AdoptPetLocationViewController: BaseViewController {
    
    private struct Segue {
        
        static let direction = "SegueDirection"
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var navigateButton: UIButton!
    
    @IBOutlet var directionView: UIView!
    
    let viewModel = AdoptPetLocationViewModel()
    
    private let locationManager = CLLocationManager()
    
    private var currentRegion: MKCoordinateRegion?
    
    private var currentPlace: CLPlacemark?
    
    private var stopPlace: CLLocation?
    
    private var mapRoutes: [MKRoute] = []
    
    private var route: Route?
    
    private var totalDistance: CLLocationDistance = 0
    
    private var totalTravelTime: TimeInterval = 0
    
    private let distanceFormatter = MKDistanceFormatter()
    
    var adoptDirectionVC: AdoptDirectionViewController?
    
    override var isHiddenTabBar: Bool { return true }
    
    override var isHiddenNavigationBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        viewModel.convertAddress { [weak self] location in

            guard
                let self = self else { return }

            self.mapView.centerToLocation(location)

            self.viewModel.addAnnotation(in: self.mapView, with: self.viewModel.petViewModel.value)

            self.stopPlace = location
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            segue.identifier == Segue.direction,
            let adoptDirectionVC = segue.destination as? AdoptDirectionViewController
                
        else { return }
        
        adoptDirectionVC.closeHandler = { [weak self] in
            
            self?.dismissPicker(adoptDirectionVC)
        }
        
        self.adoptDirectionVC = adoptDirectionVC
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
        
        totalDistance += mapRoute.distance
        
        totalTravelTime += mapRoute.expectedTravelTime
        
        mapRoutes.append(mapRoute)
        
        adoptDirectionVC?.viewModel.directionViewModel.value.direction.mapRoutes = mapRoutes
        
        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalDistance = totalDistance
        
        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalTravelTime = totalTravelTime
       
    }
    
    func showProductDirectionView() {
        
        let maxY = mapView.frame.maxY
        
        directionView.frame = CGRect(
            x: 0, y: maxY, width: UIScreen.main.bounds.height, height: 0.0
        )
        
        view.addSubview(directionView)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                
                guard
                    let strongSelf = self else { return }
                
                let height = strongSelf.view.frame.height * 0.6
                
                self?.directionView.frame = CGRect(
                    x: 0, y: maxY - height, width: UIScreen.main.bounds.width, height: height
                )
            }
        )
    }
    
    func dismissPicker(_ controller: AdoptDirectionViewController) {
        
        let origin = directionView.frame
        
        let nextFrame = CGRect(x: origin.minX, y: origin.maxY, width: origin.width, height: origin.height)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                
                self?.directionView.frame = nextFrame
                
            }, completion: { [weak self] _ in
                
                self?.directionView.removeFromSuperview()
            }
        )
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        navigateButton.isEnabled = false
        
        attemptLocationAccess()
        
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
            
            guard
                let self = self else { return }
            self.navigateButton.isEnabled = true
            
            switch result {
            case .success(let route):
                
                self.route = route
                
                self.adoptDirectionVC?.viewModel.directionViewModel.value.direction.route = route
                
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
                    
                    self.updateView(with: mapRoute)
                    
                    self.showProductDirectionView()
                    
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                }
                
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
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
}


// MARK: - CLLocationManagerDelegate
extension AdoptPetLocationViewController: CLLocationManagerDelegate {
    
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
                
                self.currentPlace = firstPlace
                
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("Error requesting location: \(error.localizedDescription)")
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
