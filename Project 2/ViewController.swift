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
    var locationItems: [LocationItem] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        let status: CLAuthorizationStatus = locationManager.authorizationStatus
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        mapView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func panInMapAt(location: CLLocation) {
        let radiusInMeters: CLLocationDistance = 1000000

        // Set the region around user location
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
        mapView.setRegion(region, animated: true)
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
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            panInMapAt(location: location)
            let locValue = location.coordinate
            let locationString =  "\(locValue.latitude),\(locValue.longitude)"
            
            api.getWeatherAt(location: locationString) { weatherResponse in
                self.addAnnotation(
                    location: location,
                    weatherResponse: weatherResponse
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status: CLAuthorizationStatus = locationManager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var view: MKMarkerAnnotationView
        let identifier = "locationAnnotation"

        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            view = annotationView
            view.annotation = annotation
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true;
            view.calloutOffset = CGPoint(x: 0, y: 10)

            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button

            if let myAnnotation = annotation as? MyAnnotation {
                print("change color")
                view.markerTintColor = myAnnotation.color
                view.glyphText = myAnnotation.tempCelsius
                let image = UIImage(systemName: myAnnotation.iconName)
                view.leftCalloutAccessoryView = UIImageView(image: image)
            }
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "DetailsViewSegue", sender: self)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let item = locationItems[indexPath.row]

        content.text = item.title
        content.secondaryText = item.description
        content.image = UIImage(systemName: "cloud")
        
        cell.contentConfiguration = content
        
        return cell
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
    
    var iconName: String {
        return weatherResponse.current.condition.getIcon()
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

struct LocationItem {
    let location: CLLocation
    let title: String
    let description: String
}
