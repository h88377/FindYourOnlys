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
    
    @IBOutlet weak var mapView: MKMapView! {
        
        didSet {
            
            mapView.delegate = self
        }
    }
    
    @IBOutlet var directionView: UIView!
    
    @IBOutlet weak var backButton: UIButton! {
        
        didSet {
            
            backButton.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var navigateButton: UIButton! {
        
        didSet {
            
            navigateButton.tintColor = .white
            
            navigateButton.setTitleColor(.white, for: .normal)
            
            navigateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            
            navigateButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet weak var searchTextField: ContentInsetTextField! {
        
        didSet {
            
            searchTextField.placeholder = "請輸入縣市進行收容所搜尋"
            
            searchTextField.textColor = .projectTextColor
        }
    }
    
    @IBOutlet weak var searchButton: UIButton! {
        
        didSet {
            
            searchButton.setTitleColor(.white, for: .normal)
            
            searchButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            searchButton.backgroundColor = .projectIconColor1
        }
    }
    
    let viewModel = AdoptPetsLocationViewModel()
    
    private let locationManager = CLLocationManager()
    
    var adoptDirectionVC: AdoptDirectionViewController?
    
    override var isHiddenNavigationBar: Bool { return true }
    
    override var isHiddenTabBar: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCalculateViews()
        
        viewModel.startLoadingHandler = { [weak self] in

            self?.startLoading()
        }
        
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
                    
//                    self.showAlertWindowAndBack(title: "注意", message: "你所在位置附近沒有收容所資訊喔！")
                    self.showAlertWindow(title: "注意", message: "你所在位置附近沒有收容所資訊喔！可以使用搜尋功能前往想去的收容所")
                    
                } else {
                    
                    self.mapView.showAnnotations(mapAnnotations, animated: true)
                }
            }
        }
        
        // Common
        attemptLocationAccess()
        
        viewModel.showDirectionHandler = { [weak self] in
            
            self?.showDirectionView()
        }
        
        viewModel.showAlertHandler = { [weak self] in
            
            self?.showAlertWindow(title: "注意", message: "請先選擇想要前往的收容所或動物的位置喔！")
        }
                
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            if
                let error = errorViewModel?.error {
                
                DispatchQueue.main.async {
                    
                    // Check user's location have shelters' information
                    if self?.viewModel.shelterViewModels.value != nil {
                        
                        // Filter out error message when occured error but already have annotations on the map to enhance UX.
                        if self?.viewModel.mapAnnotationViewModels.value == nil {
                            
                            if
                                let httpClientError = error as? HTTPClientError {
                                
                                self?.showAlertWindow(title: "異常訊息", message: "\(httpClientError.errorMessage)")
                                
                            } else if
                                let mapError = error as? MapError {
                                
                                self?.showAlertWindow(title: "異常訊息", message: "\(mapError.errorMessage)")
                            }
                        }
                        
                    } else {
                        
                        if
                            let httpClientError = error as? HTTPClientError {
                            
                            self?.showAlertWindow(title: "異常訊息", message: "\(httpClientError.errorMessage)")
                            
                        } else if
                            let mapError = error as? MapError {
                            
                            self?.showAlertWindow(title: "異常訊息", message: "\(mapError.errorMessage)")
                        }
                    }
                }
            }
            
//            guard
//                let errorViewModel = errorViewModel else { return }
            
            // Check user's location have shelters' information
//            if self?.viewModel.shelterViewModels.value != nil {
                
                // Filter out error message when occured error but already have annotations on the map to enhance UX.
//                if self?.viewModel.mapAnnotationViewModels.value == nil {
//
//                    self?.showAlertWindow(title: "異常訊息", message: "\(String(describing: errorViewModel.error))")
//                }
//
//            } else {
//
//                self?.showAlertWindow(title: "異常訊息", message: "\(String(describing: errorViewModel.error))")
//            }
        }
        
        viewModel.stopLoadingHandler = { [weak self] in

            self?.stopLoading()
        }
        
        setupGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        navigateButton.layer.cornerRadius = 15
        
        directionView.roundCorners(corners: [.topLeft, .topRight], radius: 25)
    }
    
    // Pets
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        viewModel.calculateRoute()
    }
    
    @IBAction func searchShelter(_ sender: UIButton) {
        
        guard
            let searchText = searchTextField.text
                
        else {
            
            showAlertWindow(title: "請輸入縣市", message: "")
            
            return
        }
        
        viewModel.fetchShelter(with: searchText)
        
        viewModel.isSearch = true
        mapView.removeAnnotations(mapView.annotations)
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
        
        adoptDirectionVC?.viewModel.directionViewModel.value = DirectionViewModel(
            model: Direction(
                route: viewModel.routeViewModel.value.route,
                mapRoutes: [mapRoute],
                totalDistance: totalDistance,
                totalTravelTime: totalTravelTime
            )
        )
        
//        adoptDirectionVC?.viewModel.directionViewModel.value.direction.mapRoutes = [mapRoute]
//
//        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalDistance = totalDistance
//
//        adoptDirectionVC?.viewModel.directionViewModel.value.direction.totalTravelTime = totalTravelTime
//
//        adoptDirectionVC?.viewModel.directionViewModel.value.direction.route = viewModel.routeViewModel.value.route
        
    }
    
    // Common
    
    func setupCalculateViews() {
        
        searchButton.isHidden = !viewModel.isShelterMap
        
        searchTextField.isHidden = !viewModel.isShelterMap
        
    }
    
    func showDirectionView() {
        
        let maxY = mapView.frame.maxY
        
        directionView.frame = CGRect(
            x: 0, y: maxY, width: UIScreen.main.bounds.width, height: 0.0
        )
        
        view.addSubview(directionView)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                
                guard
                    let strongSelf = self else { return }
                
                let height = strongSelf.view.frame.height * 0.4
                
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
    
    func setupGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDirectionView))
        
        directionView.addGestureRecognizer(tapGesture)
        
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
    
    @objc func tapDirectionView(sender: UITapGestureRecognizer) {
        
        let maxY = mapView.frame.maxY
        
        let highHeight = view.frame.height * 0.7
        
        let lowHeight = view.frame.height * 0.4
        
        if sender.state == .ended {
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                
                if self?.directionView.frame.height == lowHeight {
                    
                    self?.directionView.frame = CGRect(
                        x: 0, y: maxY - highHeight, width: UIScreen.main.bounds.width, height: highHeight
                    )
                    
                } else {
                    
                    self?.directionView.frame = CGRect(
                        x: 0, y: maxY - lowHeight, width: UIScreen.main.bounds.width, height: highHeight
                    )
                }
                
            } completion: { [weak self] _ in
                
                if self?.directionView.frame.minY == maxY - lowHeight {
                    
                    self?.directionView.frame = CGRect(
                        x: 0, y: maxY - lowHeight, width: UIScreen.main.bounds.width, height: lowHeight
                    )
                }
            }

        }
    }
    
    func showAlertWindowAndBack(title: String, message: String?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
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
                        
                else {
                    
                    self?.showAlertWindow(title: "異常", message: "無法取得所在位置，請確認網路連線")
                    
                    return
                }
                
                let currentAnnotation = MapAnnotation(
                    title: "現在位置", subtitle: "\(firstPlace.abbreviation)", location: "\(firstPlace)",
                    coordinate: CLLocationCoordinate2D(latitude: firstLocation.coordinate.latitude, longitude: firstLocation.coordinate.longitude)
                )
                self.viewModel.currentMapAnnotation.value.mapAnnotation = currentAnnotation
                
                self.viewModel.currentLocationViewModel.value.location = firstLocation
                
                // Mock location because Taipei don't have any shelter.
                
//                self.viewModel.fetchShelter(with: "新北市")
                
                self.viewModel.fetchShelter(with: firstPlace.subAdministrativeArea ?? "新北市")
            }
        }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print("=====Error requesting location: \(error.localizedDescription)")
        showAlertWindow(title: "取得所在位置異常", message: "請確認網路狀況或者允許該應用程式取得您裝置的所在位置")
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
