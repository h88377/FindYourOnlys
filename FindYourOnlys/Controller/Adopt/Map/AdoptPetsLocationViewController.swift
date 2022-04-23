//
//  AdoptPetsLocationViewController.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//

import UIKit
import MapKit

class AdoptPetsLocationViewController: BaseViewController {
    
    private struct Segue {
        
        static let direction = "SegueDirection"
    }
    
    let viewModel = AdoptPetsLocationViewModel()
    
    private let locationManager = CLLocationManager()
    
    var adoptDirectionVC: AdoptDirectionViewController?
    
    override var isHiddenNavigationBar: Bool { return true }
    
    override var isHiddenTabBar: Bool { return true }
    
    @IBOutlet weak var mapView: MKMapView! {
        
        didSet {
            
            mapView.delegate = self
        }
    }
    
    @IBOutlet var directionView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pet
        viewModel.convertAddress()
        
        viewModel.getPetLocationHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.mapView.centerToLocation(self.viewModel.locationViewModel.value.location)
            
            self.mapView.addAnnotation(self.viewModel.selectedMapAnnotation.value.mapAnnotation)
        }
        
        
        
        // Pets
        viewModel.getUserLocationHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.mapView.centerToLocation(self.viewModel.currentLocationViewModel.value.location)
            
            self.mapView.addAnnotation(self.viewModel.currentMapAnnotation.value.mapAnnotation)
            
            self.updateView(with: self.viewModel.mapRouteViewModel.value.mapRoute)
        }
        
        viewModel.mapAnnotationViewModels.bind { [weak self] mapAnnotationViewModels in
            
            guard
                let mapAnnotationViewModels = mapAnnotationViewModels,
                let self = self else { return }
            
            let mapAnnotations = mapAnnotationViewModels.map { $0.mapAnnotation }
            
            DispatchQueue.main.async {
                
                self.mapView.addAnnotations(mapAnnotations)
                
                if mapAnnotations.count == 0 {
                    
                    self.showAlertWindow(title: "異常訊息", message: "你所在位置附近沒有收容所資訊喔！")
                    
                } else {
                    
                    self.mapView.showAnnotations(mapAnnotations, animated: true)
                }
            }
        }
        
        // Common
        attemptLocationAccess()
        
        viewModel.showDirectionHandler = { [weak self] in
            
            self?.showProductDirectionView()
        }
        
        viewModel.showAlertHandler = { [weak self] in
            
            self?.showAlertWindow(title: "異常訊息", message: "請先選擇你的目的地喔！")
        }
                
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let errorViewModel = errorViewModel else { return }
            
            self?.showAlertWindow(title: "異常訊息", message: "\(String(describing: errorViewModel.error))")
        }
        
    }
    
    // Pets
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        viewModel.calculateRoute()
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
        
        let totalDistance = mapRoute.distance
        
        let totalTravelTime = mapRoute.expectedTravelTime
        
        adoptDirectionVC?.viewModel.directionViewModel.value.direction.mapRoutes = [mapRoute]
        
        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalDistance = totalDistance
        
        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalTravelTime = totalTravelTime
        
        adoptDirectionVC?.viewModel.directionViewModel.value.direction.route = viewModel.routeViewModel.value.route
        
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
    
    func dismiss(_ controller: AdoptDirectionViewController) {
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            segue.identifier == Segue.direction,
            let adoptDirectionVC = segue.destination as? AdoptDirectionViewController
                
        else { return }
        
        adoptDirectionVC.closeHandler = { [weak self] in
            
            self?.dismiss(adoptDirectionVC)
        }
        
        self.adoptDirectionVC = adoptDirectionVC
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
                
                self.viewModel.fetchShelter(with: "新北市")
                
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
