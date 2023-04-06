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
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    private func setupMap() {
        // mapView.showsUserLocation = true
        
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
        
        // Get temperature and add the annotation
        api.getWeatherAt(location: locationString) { weatherResponse in
            self.addAnnotation(
                location: currentLocation,
                weatherResponse: weatherResponse
            )
        }
    }
    
    private func addAnnotation(location: CLLocation, weatherResponse: WeatherResponse) {
        let annotation = MyAnnotation(
            coordinate: location.coordinate,
            weatherResponse: weatherResponse
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

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "currentLocationAnnotation"
        let view: MKMarkerAnnotationView
        view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        view.canShowCallout = true;
        view.calloutOffset = CGPoint(x: 0, y: 10)
        
        let button = UIButton(type: .detailDisclosure)
        view.rightCalloutAccessoryView = button
        
        if let myAnnotation = annotation as? MyAnnotation {
            view.markerTintColor = myAnnotation.color
            view.glyphText = myAnnotation.tempCelsius
        }
        return view
    }
}

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var weatherResponse: WeatherResponse
    
    var title: String?
    var subtitle: String?
    
    var color: UIColor {
        let tempCelsius = weatherResponse.current.temp_c
        
        if tempCelsius < 0 {
            return #colorLiteral(red: 1, green: 0.2527923882, blue: 1, alpha: 1)
        } else if tempCelsius <= 11 {
            return #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        } else if tempCelsius <= 16 {
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        } else if tempCelsius <= 24 {
            return #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        } else if tempCelsius <= 30 {
            return #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        } else {
            return #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
        }
    }
    
    var tempCelsius: String {
        return "\(weatherResponse.current.temp_c)"
    }
    
    init(coordinate: CLLocationCoordinate2D, weatherResponse: WeatherResponse) {
        self.coordinate = coordinate
        self.weatherResponse = weatherResponse
        self.title = weatherResponse.current.condition.text
        self.subtitle = "Current: \(weatherResponse.current.temp_c)C. Feels Like: \(weatherResponse.current.feelslike_c)C"
        super.init()
    }
}
