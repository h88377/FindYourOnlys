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
    
    // MARK: - Properties
    
    let viewModel = AdoptPetsLocationViewModel()
    
    private let locationManager = CLLocationManager()
    
    private var adoptDirectionVC: AdoptDirectionViewController?
    
    @IBOutlet private weak var mapView: MKMapView! {
        
        didSet {
            
            mapView.delegate = self
        }
    }
    
    @IBOutlet private var directionView: UIView!
    
    @IBOutlet private weak var backButton: UIButton! {
        
        didSet {
            
            backButton.tintColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var navigateButton: TransformButton! {
        
        didSet {
            
            navigateButton.tintColor = .white
            
            navigateButton.setTitleColor(.white, for: .normal)
            
            navigateButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            
            navigateButton.backgroundColor = .projectIconColor1
        }
    }
    
    @IBOutlet private weak var searchTextField: ContentInsetTextField! {
        
        didSet {
            
            searchTextField.placeholder = "請輸入縣市進行收容所搜尋"
            
            searchTextField.textColor = .projectTextColor
            
            searchTextField.alpha = 0.8
        }
    }
    
    @IBOutlet private weak var searchButton: UIButton! {
        
        didSet {
            
            searchButton.setTitleColor(.white, for: .normal)
            
            searchButton.setTitleColor(.projectIconColor2, for: .highlighted)
            
            searchButton.backgroundColor = .projectIconColor1
        }
    }
    
    override var isHiddenNavigationBar: Bool { return true }
    
    override var isHiddenTabBar: Bool { return true }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.mapAnnotationViewModels.bind { [weak self] mapAnnotationViewModels in
            
            guard
                let mapAnnotationViewModels = mapAnnotationViewModels,
                let self = self else { return }
            
            let mapAnnotations = mapAnnotationViewModels.map { $0.mapAnnotation }
            
            DispatchQueue.main.async {
                
                self.mapView.addAnnotations(mapAnnotations)
                
                if mapAnnotations.count == 0 {
                    
                    self.showAlertWindow(title: "注意", message: "你所在位置或搜尋縣市附近沒有收容所資訊喔！")
                    
                } else {
                    
                    self.mapView.showAnnotations(mapAnnotations, animated: true)
                }
            }
        }
        
        viewModel.errorViewModel.bind { [weak self] errorViewModel in
            
            guard
                let self = self else { return }
            
            if
                let error = errorViewModel?.error {
                    
                // Check user's location have shelters' information
                if self.viewModel.shelterViewModels.value != nil {
                    
                    // Filter out error message when occured error,
                    // but already have annotations on the map to enhance UX.
                    if self.viewModel.mapAnnotationViewModels.value == nil {
                        
                        self.showAlertWindow(of: error)
                    }
                    
                } else {
                    
                    self.showAlertWindow(of: error)
                }
            }
        }
        
        viewModel.showDirectionHandler = { [weak self] in
            
            self?.showDirectionView()
        }
        
        viewModel.showAlertHandler = { [weak self] in
            
            self?.showAlertWindow(title: "注意", message: "請先選擇想要前往的收容所或動物的位置喔！")
        }
        
        configureLoadingView()
        
        getLocationAnnotations()
        
        setupSearchViews()
        
        setupGesture()
        
        attemptLocationAccess()
        
        viewModel.convertAddress()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        navigateButton.layer.cornerRadius = 15
        
        searchButton.layer.cornerRadius = 15
        
        directionView.roundCorners(corners: [.topLeft, .topRight], radius: 25)
    }
    
    // MARK: - Methods and IBActions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard
            segue.identifier == Segue.direction,
            let adoptDirectionVC = segue.destination as? AdoptDirectionViewController
                
        else { return }
        
        adoptDirectionVC.closeHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.dismiss(adoptDirectionVC)
        }
        
        self.adoptDirectionVC = adoptDirectionVC
    }
    
    private func configureLoadingView() {
        
        viewModel.startLoadingHandler = { [weak self] in
            
            guard
                let self = self else { return }

            self.startLoading()
        }
        
        viewModel.stopLoadingHandler = { [weak self] in
            
            guard
                let self = self else { return }

            self.stopLoading()
        }
    }
    
    private func getLocationAnnotations() {
        
        viewModel.getPetLocationHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.mapView.centerToLocation(self.viewModel.locationViewModel.value.location)
            
            self.mapView.addAnnotation(self.viewModel.selectedMapAnnotation.value.mapAnnotation)
        }
           
        viewModel.getUserLocationHandler = { [weak self] in
            
            guard
                let self = self else { return }
            
            self.mapView.centerToLocation(self.viewModel.currentLocationViewModel.value.location)
            
            self.mapView.addAnnotation(self.viewModel.currentMapAnnotation.value.mapAnnotation)
            
            self.updateView(with: self.viewModel.mapRouteViewModel.value.mapRoute)
        }
    }
    
    private func attemptLocationAccess() {
        
        guard
            CLLocationManager.locationServicesEnabled() else { return }
        
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
        
        mapView.showAnnotations(
            [viewModel.currentMapAnnotation.value.mapAnnotation,
             viewModel.selectedMapAnnotation.value.mapAnnotation],
            animated: true
        )
        
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
    }
    
    func setupSearchViews() {
        
        searchButton.isHidden = !viewModel.isShelterMap
        
        searchTextField.isHidden = !viewModel.isShelterMap
    }
    
    func showDirectionView() {
        
        let maxY = mapView.frame.maxY
        
        directionView.frame = CGRect(
            x: 0, y: maxY,
            width: UIScreen.main.bounds.width,
            height: 0.0
        )
        
        view.addSubview(directionView)
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                
                guard
                    let self = self else { return }
                
                let height = self.view.frame.height * 0.4
                
                self.directionView.frame = CGRect(
                    x: 0, y: maxY - height,
                    width: UIScreen.main.bounds.width,
                    height: height
                )
            }
        )
    }
    
    func dismiss(_ controller: AdoptDirectionViewController) {
        
        let origin = directionView.frame
        
        let nextFrame = CGRect(
            x: origin.minX, y: origin.maxY,
            width: origin.width,
            height: origin.height
        )
        
        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in
                
                guard
                    let self = self else { return }
                
                self.directionView.frame = nextFrame
                
            }, completion: { [weak self] _ in
                
                guard
                    let self = self else { return }
                
                self.directionView.removeFromSuperview()
            }
        )
    }
    
    func setupGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDirectionView))
        
        directionView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func tapDirectionView(sender: UITapGestureRecognizer) {
        
        let maxY = mapView.frame.maxY
        
        let screenWidth = UIScreen.main.bounds.width
        
        let highHeight = view.frame.height * 0.7
        
        let lowHeight = view.frame.height * 0.4
        
        if sender.state == .ended {
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                
                guard
                    let self = self else { return }
                
                if self.directionView.frame.height == lowHeight {
                    
                    self.directionView.frame = CGRect(
                        x: 0, y: maxY - highHeight,
                        width: screenWidth,
                        height: highHeight
                    )
                    
                } else {
                    
                    self.directionView.frame = CGRect(
                        x: 0, y: maxY - lowHeight,
                        width: screenWidth,
                        height: highHeight
                    )
                }
                
            } completion: { [weak self] _ in
                
                guard
                    let self = self else { return }
                
                if self.directionView.frame.minY == maxY - lowHeight {
                    
                    self.directionView.frame = CGRect(
                        x: 0, y: maxY - lowHeight,
                        width: screenWidth,
                        height: lowHeight
                    )
                }
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func navigate(_ sender: UIButton) {
        
        viewModel.calculateRoute()
    }
    
    @IBAction func searchShelter(_ sender: UIButton) {
        
        guard
            let searchText = searchTextField.text,
            searchText != ""
                
        else {
            
            showAlertWindow(title: "請輸入縣市")
            
            return
        }
        
        viewModel.isSearch = true
        
        viewModel.fetchShelter(with: searchText)
        
        viewModel.selectedMapAnnotation.value = MapAnnotationViewModel(
            model: MapAnnotation(
                title: "",
                subtitle: "",
                location: "",
                coordinate: CLLocationCoordinate2D())
        )
        
        mapView.removeAnnotations(mapView.annotations)
        
        if
            mapView.overlays.count != 0 {
            
            mapView.removeOverlay(mapView.overlays[0])
        }
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
            
            startLoading()
            
            CLGeocoder().reverseGeocodeLocation(firstLocation) { [weak self] places, _ in
                
                guard
                    let firstPlace = places?.first,
                    let self = self
                        
                else {
                    
                    self?.showAlertWindow(title: "異常", message: "無法取得所在位置，請確認網路連線")
                    
                    self?.stopLoading()
                    
                    return
                }
                
                let currentAnnotation = MapAnnotation(
                    title: "現在位置", subtitle: "\(firstPlace.abbreviation)", location: "\(firstPlace)",
                    coordinate: CLLocationCoordinate2D(latitude: firstLocation.coordinate.latitude, longitude: firstLocation.coordinate.longitude)
                )
                self.viewModel.currentMapAnnotation.value.mapAnnotation = currentAnnotation
                
                self.viewModel.currentLocationViewModel.value.location = firstLocation
                
                self.stopLoading()
                
                // Mock location because Taipei don't have any shelter.
                
//                self.viewModel.fetchShelter(with: "台北市")
                
                if firstPlace.subAdministrativeArea == "台北市" {
                    
                    self.viewModel.fetchShelter(with: "臺北市")
                    
                } else if firstPlace.subAdministrativeArea == "台中市" {
                    
                    self.viewModel.fetchShelter(with: "臺中市")
                    
                } else if firstPlace.subAdministrativeArea == "台南市" {
                    
                    self.viewModel.fetchShelter(with: "臺南市")
                    
                } else if firstPlace.subAdministrativeArea == "台東市" {
                
                    self.viewModel.fetchShelter(with: "臺東市")
                    
                } else if firstPlace.subAdministrativeArea == "台東縣" {
                    
                    self.viewModel.fetchShelter(with: "臺東縣")
                    
                } else {
                    
                    self.viewModel.fetchShelter(with: firstPlace.subAdministrativeArea ?? "新北市")
                }
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
