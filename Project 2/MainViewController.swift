//
//  ViewController.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import UIKit
import MapKit

let CELSIUS_UNIT = "°C"
let RADIUS_IN_METERS: CLLocationDistance = 1000000

class MainViewController: UIViewController {
    private let locationManager = CLLocationManager()
    private let api = WeatherAPIWrapper()
    var locationItems: [LocationItem] = []
    var currentCoordinate: CLLocationCoordinate2D?
    
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

    // Set region and pan in a location
    private func panInMapAt(location: CLLocation) {
        let region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: RADIUS_IN_METERS,
            longitudinalMeters: RADIUS_IN_METERS
        )
        mapView.setRegion(region, animated: true)
    }
    
    // Add an annotation to the mapView
    private func addAnnotation(location: CLLocation, weatherResponse: WeatherResponse) {
        let annotation = MyAnnotation(
            coordinate: location.coordinate,
            weatherResponse: weatherResponse
        )
        
        mapView.addAnnotation(annotation)
    }
    
    // Prepare the coordinate before navigating to the Details View
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsViewSegue" {
            let destination = segue.destination as! DetailsViewController
            destination.currentCoordinate = self.currentCoordinate
        }
    }
    
    // Called when click Save on AddLocationController
    // Add location to the list and to the map and pan in to the location
    @IBAction func unwindFromDetailsViewController(_ sender: UIStoryboardSegue) {
        if sender.source is AddLocationController {
            if let destination = sender.source as? AddLocationController {
                if let location = destination.location,
                   let weatherResponse = destination.weatherResponse
                {
                    addAnnotation(location: location, weatherResponse: weatherResponse)
                    locationItems.append(LocationItem(location: location, weatherResponse: weatherResponse))
                    tableView.reloadData()
                    panInMapAt(location: location)
                }
            }
        }
    }
}

extension MainViewController: CLLocationManagerDelegate {
    // Add an annotation when user location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let locValue = location.coordinate
            let locationString =  "\(locValue.latitude),\(locValue.longitude)"
            
            api.getWeatherForecastAt(location: locationString) { weatherResponse in
                DispatchQueue.main.async {
                    self.panInMapAt(location: location)
                    self.addAnnotation(location: location,weatherResponse: weatherResponse)
                    self.locationItems.append(LocationItem(location: location, weatherResponse: weatherResponse))
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // Start update location when permission is granted
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let status: CLAuthorizationStatus = locationManager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}

extension MainViewController: MKMapViewDelegate {
    // Create AnnotationView for an annotation
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

        }
        
        if let myAnnotation = annotation as? MyAnnotation {
            view.markerTintColor = myAnnotation.color
            view.glyphText = myAnnotation.tempCelsiusString
            let image = UIImage(systemName: myAnnotation.iconName)
            view.leftCalloutAccessoryView = UIImageView(image: image)
        }
        
        return view
    }
    
    // Go to detail view when Callout Accessory Control is tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MyAnnotation {
            self.currentCoordinate = annotation.coordinate
        }
        performSegue(withIdentifier: "DetailsViewSegue", sender: self)
    }
}

extension MainViewController: UITableViewDelegate {
    // Select on each cell and pan in the location
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = locationItems[indexPath.row]
        panInMapAt(location: item.location)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationItems.count
    }
    
    // Create view for each table cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let item = locationItems[indexPath.row]

        content.text = item.title
        content.secondaryText = item.description
        content.image = UIImage(systemName: item.iconName)
        
        cell.contentConfiguration = content
        
        return cell
    }
}

// Customized annotation on the map
class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var weatherResponse: WeatherResponse
    
    var title: String? {
        return weatherResponse.conditionText
    }
    var subtitle: String? {
        return "Current: \(weatherResponse.tempCelsius)\(CELSIUS_UNIT). Feels Like: \(weatherResponse.tempFeelLikeCelsius)\(CELSIUS_UNIT)"
    }
    
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
        return weatherResponse.conditionIconName
    }
    
    var tempCelsiusString: String {
        return "\(weatherResponse.tempCelsius)"
    }
    
    init(coordinate: CLLocationCoordinate2D, weatherResponse: WeatherResponse) {
        self.coordinate = coordinate
        self.weatherResponse = weatherResponse
        
        super.init()
    }
}

struct LocationItem {
    let location: CLLocation
    let weatherResponse: WeatherResponse
    
    var title: String {
        return weatherResponse.locationName
    }
    
    var description: String? {
        if let lowCelsius = weatherResponse.lowCelsius,
           let highCelsius = weatherResponse.highCelsius
        {
            return "\(weatherResponse.tempCelsius)\(CELSIUS_UNIT) (H: \(highCelsius)\(CELSIUS_UNIT), L: \(lowCelsius)\(CELSIUS_UNIT))"
        }
        return nil
    }
    
    var iconName: String {
        return weatherResponse.conditionIconName
    }
    
    init(location: CLLocation, weatherResponse: WeatherResponse) {
        self.location = location
        self.weatherResponse = weatherResponse
    }
}
