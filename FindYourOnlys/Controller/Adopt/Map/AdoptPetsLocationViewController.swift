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
            
            self.mapView.addAnnotations(mapAnnotations)
            
            if mapAnnotations.isEmpty {
                
                AlertWindowManager.shared.showAlertWindow(at: self, title: "注意", message: "你所在位置或搜尋縣市附近沒有收容所資訊喔！")
                
            } else {
                
                self.mapView.showAnnotations(mapAnnotations, animated: true)
            }
        }

        // After lose network, calculateRouteError would not be satisfied by using below conditions.
        viewModel.errorViewModel.bind { [weak self] errorViewModel in

            guard let self = self else { return }

            if let error = errorViewModel?.error {

                // Check user's location if have shelters' information
                if self.viewModel.shelters != nil {

                    // Filter out alert window when there are annotations on the map to enhance UX.
                    if self.viewModel.mapAnnotationViewModels.value == nil {

                        AlertWindowManager.shared.showAlertWindow(at: self, of: error)
                    }

                } else {

                    AlertWindowManager.shared.showAlertWindow(at: self, of: error)
                }
            }
        }

        viewModel.showDirectionHandler = { [weak self] in

            guard let self = self else { return }

            self.showDirectionView()
        }

        viewModel.showAlertHandler = { [weak self] in

            guard let self = self else { return }

            AlertWindowManager.shared.showAlertWindow(at: self, title: "注意", message: "請先選擇想要前往的收容所或動物的位置喔！")
        }

        setupLocationAnnotationsHandler()

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

            guard let self = self else { return }

            self.dismiss(adoptDirectionVC)
        }

        self.adoptDirectionVC = adoptDirectionVC
    }
    
    override func setupLoadingViewHandler() {
        
        viewModel.startLoadingHandler = { [weak self] in

            guard let self = self else { return }

            self.startLoading()
        }

        viewModel.stopLoadingHandler = { [weak self] in

            guard let self = self else { return }

            self.stopLoading()
        }
    }

    private func setupLocationAnnotationsHandler() {

        viewModel.getPetLocationHandler = { [weak self] in

            guard
                let self = self,
                let petLocation = self.viewModel.petLocation,
                let selectedMapAnnotation = self.viewModel.selectedMapAnnotation
            else { return }

            self.mapView.centerToLocation(petLocation)

            self.mapView.addAnnotation(selectedMapAnnotation)
        }

        viewModel.getUserLocationHandler = { [weak self] in

            guard
                let self = self,
                let currentLocation = self.viewModel.currentLocation,
                let currentMapAnnotation = self.viewModel.currentMapAnnotation,
                let mapRoute = self.viewModel.mapRoute
            else { return }

            self.mapView.centerToLocation(currentLocation)

            self.mapView.addAnnotation(currentMapAnnotation)

            self.updateView(with: mapRoute)
        }
    }

    private func attemptLocationAccess() {

        guard CLLocationManager.locationServicesEnabled() else { return }

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        locationManager.delegate = self

        if CLLocationManager.authorizationStatus() == .notDetermined {

            locationManager.requestWhenInUseAuthorization()

        } else {

            locationManager.requestLocation()
        }
    }

    private func updateView(with mapRoute: MKRoute) {

        guard
            let currentMapAnnotation = viewModel.currentMapAnnotation,
            let selectedMapAnnotation = viewModel.selectedMapAnnotation,
            let route = viewModel.route
        else { return }

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
                right: padding),
            animated: true)

        mapView.showAnnotations([currentMapAnnotation, selectedMapAnnotation], animated: true)

        let totalDistance = mapRoute.distance

        let totalTravelTime = mapRoute.expectedTravelTime
        
        adoptDirectionVC?.viewModel.directionViewModel.value = DirectionViewModel(
            model: Direction(
                route: route,
                mapRoutes: [mapRoute],
                totalDistance: totalDistance,
                totalTravelTime: totalTravelTime))
    }

    private func setupSearchViews() {

        searchButton.isHidden = !viewModel.isShelterMap

        searchTextField.isHidden = !viewModel.isShelterMap
    }

    private func showDirectionView() {

        let maxY = mapView.frame.maxY
        
        let screenWidth = UIScreen.main.bounds.width

        directionView.frame = CGRect(
            x: 0, y: maxY,
            width: screenWidth,
            height: 0.0)

        view.addSubview(directionView)

        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in

                guard let self = self else { return }

                let height = self.view.frame.height * 0.4

                self.directionView.frame = CGRect(
                    x: 0, y: maxY - height,
                    width: screenWidth,
                    height: height)
            }
        )
    }

    private func dismiss(_ controller: AdoptDirectionViewController) {

        let origin = directionView.frame

        let nextFrame = CGRect(
            x: origin.minX, y: origin.maxY,
            width: origin.width,
            height: origin.height)

        UIView.animate(
            withDuration: 0.3,
            animations: { [weak self] in

                guard let self = self else { return }

                self.directionView.frame = nextFrame

            }, completion: { [weak self] _ in

                guard let self = self else { return }

                self.directionView.removeFromSuperview()
            }
        )
    }

    private func setupGesture() {

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDirectionView))

        directionView.addGestureRecognizer(tapGesture)
    }

    @objc private func tapDirectionView(sender: UITapGestureRecognizer) {

        let maxY = mapView.frame.maxY

        let screenWidth = UIScreen.main.bounds.width

        let highHeight = view.frame.height * 0.7

        let lowHeight = view.frame.height * 0.4

        if sender.state == .ended {

            UIView.animate(withDuration: 0.3) { [weak self] in

                guard let self = self else { return }

                if self.directionView.frame.height == lowHeight {

                    self.directionView.frame = CGRect(
                        x: 0, y: maxY - highHeight,
                        width: screenWidth,
                        height: highHeight)

                } else {

                    self.directionView.frame = CGRect(
                        x: 0, y: maxY - lowHeight,
                        width: screenWidth,
                        height: highHeight)
                }

            } completion: { [weak self] _ in

                guard let self = self else { return }

                if self.directionView.frame.minY == maxY - lowHeight {

                    self.directionView.frame = CGRect(
                        x: 0, y: maxY - lowHeight,
                        width: screenWidth,
                        height: lowHeight)
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
            
            AlertWindowManager.shared.showAlertWindow(at: self, title: "請輸入縣市")

            return
        }

        viewModel.isSearch = true

        viewModel.fetchShelter(with: searchText)

        viewModel.selectedMapAnnotation = MapAnnotation()

        mapView.removeAnnotations(mapView.annotations)

        if mapView.overlays.count != 0 {

            mapView.removeOverlay(mapView.overlays[0])
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AdoptPetsLocationViewController: CLLocationManagerDelegate {

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {

            guard status == .authorizedWhenInUse else { return }
            
            manager.requestLocation()
        }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

            guard
                let firstLocation = locations.first else { return }

            startLoading()

            CLGeocoder().reverseGeocodeLocation(firstLocation) { [weak self] places, _ in

                guard
                    let firstPlace = places?.first,
                    let city = firstPlace.subAdministrativeArea,
                    let self = self
                else {

                    AlertWindowManager.shared.showAlertWindow(at: self!, title: "異常", message: "無法取得所在位置，請確認網路連線")

                    self?.stopLoading()

                    return
                }

                let coordinate = firstLocation.coordinate

                let currentAnnotation = MapAnnotation(
                    title: "現在位置",
                    subtitle: "\(firstPlace.abbreviation)",
                    location: "\(firstPlace)",
                    coordinate: CLLocationCoordinate2D(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                )

                self.viewModel.currentMapAnnotation = currentAnnotation

                self.viewModel.currentLocation = firstLocation

                self.stopLoading()

                switch city {

                case "台北市":

                    self.viewModel.fetchShelter(with: "臺北市")

                case "台中市":

                    self.viewModel.fetchShelter(with: "臺中市")

                case "台南市":

                    self.viewModel.fetchShelter(with: "臺南市")

                case "台東市":

                    self.viewModel.fetchShelter(with: "臺東市")

                case "台東縣":

                    self.viewModel.fetchShelter(with: "臺東縣")

                default:

                    self.viewModel.fetchShelter(with: city)
                }
            }
        }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        AlertWindowManager.shared.showAlertWindow(
            at: self,
            title: "取得所在位置異常",
            message: "請確認網路狀況或者允許該應用程式取得您裝置的所在位置")
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
            let selectedMapAnnotation = view.annotation as? MapAnnotation else { return }

        viewModel.selectedMapAnnotation = selectedMapAnnotation
    }
}
