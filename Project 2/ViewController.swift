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
    private let api = WeatherAPIWrapper()
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupMap() {
//        mapView.showsUserLocation = true
        
        guard let currentLocation = locationManager.location else { return }
        let locValue = currentLocation.coordinate
        let locationString =  "\(locValue.latitude),\(locValue.longitude)"
        let radiusInMeters: CLLocationDistance = 1000000

        // Set the region around user location
        let region = MKCoordinateRegion(
            center: currentLocation.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
        mapView.setRegion(region, animated: true)
        
        api.getWeatherAt(location: locationString) { weatherReponse in
            self.addAnnotation(
                location: currentLocation,
                tempCelsius: weatherReponse.current.temp_c
            )
        }
    }
    
    private func addAnnotation(location: CLLocation, tempCelsius: Double) {
        let annotation = MyAnnotation(
            coordinate: location.coordinate,
            title: "\(tempCelsius)C"
        )
        mapView.addAnnotation(annotation)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        // Setup map region when location is updated
        setupMap()
    }
}

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?) {
        self.coordinate = coordinate
        self.title = title
        super.init()
    }
}
