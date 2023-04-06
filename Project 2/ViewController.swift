//
//  ViewController.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupMap() {
        mapView.showsUserLocation = true
        
        guard let currentLocation = locationManager.location else { return }
        print(currentLocation)
        let radiusInMeters: CLLocationDistance = 1000000

        // Set the region around user location
        let region = MKCoordinateRegion(
            center: currentLocation.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
        mapView.setRegion(region, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        setupMap()
    }
}
