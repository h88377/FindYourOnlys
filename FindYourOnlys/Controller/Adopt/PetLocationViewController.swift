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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.convertAddress { [weak self] location in
            
            self?.mapView.centerToLocation(location)
        }
        

//        let oahuCenter = CLLocation(latitude: 21.4765, longitude: -157.9647)
//        let region = MKCoordinateRegion(
//          center: oahuCenter.coordinate,
//          latitudinalMeters: 50000,
//          longitudinalMeters: 60000)
//        mapView.setCameraBoundary(
//          MKMapView.CameraBoundary(coordinateRegion: region),
//          animated: true)
//
//        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
//        mapView.setCameraZoomRange(zoomRange, animated: true)


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
