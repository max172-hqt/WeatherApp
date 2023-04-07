//
//  ViewController.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import UIKit
import MapKit

let CELSIUS_UNIT = "°C"

class ViewController: UIViewController {
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

    // Set region for a location
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
            tempCelsius: weatherResponse.current.temp_c,
            tempFeelLikeCelsius: weatherResponse.current.feelslike_c,
            iconName: weatherResponse.current.condition.getIcon(),
            condition: weatherResponse.current.condition.text
        )
        
        mapView.addAnnotation(annotation)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsViewSegue" {
            let destination = segue.destination as! DetailsViewController
            destination.currentCoordinate = self.currentCoordinate
        }
    }
    
    @IBAction func unwindFromDetailsViewController(_ sender: UIStoryboardSegue) {
        if sender.source is AddLocationController {
            if let destination = sender.source as? AddLocationController {
                if let locationName = destination.locationName,
                   let location = destination.location,
                   let lowTemperature = destination.lowTemperature,
                   let highTemperature = destination.highTemperature,
                   let temperature = destination.temperature,
                   let weatherResponse = destination.weatherResponse
                {
                    let description = "\(temperature)\(CELSIUS_UNIT) (H: \(highTemperature)\(CELSIUS_UNIT), L: \(lowTemperature)\(CELSIUS_UNIT))"
                    locationItems.append(LocationItem(location: location,
                                                      title: locationName,
                                                      description: description,
                                                      iconName: weatherResponse.current.condition.getIcon()))
                    tableView.reloadData()
                    addAnnotation(location: location, weatherResponse: weatherResponse)
                }
            }
        }
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    // Add an annotation when location is updated
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
    
    // Start update location when permission is granted
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = locationItems[indexPath.row]
        panInMapAt(location: item.location)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationItems.count
    }
    
    // TODO: Update the information
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
    var tempCelsius: Double
    var iconName: String
    
    var title: String?
    var subtitle: String?
    
    var color: UIColor {
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
    
    var tempCelsiusString: String {
        return "\(tempCelsius)"
    }
    
    init(coordinate: CLLocationCoordinate2D,
         tempCelsius: Double,
         tempFeelLikeCelsius: Double,
         iconName: String,
         condition: String
    ) {
        self.coordinate = coordinate
        self.title = condition
        self.subtitle = "Current: \(tempCelsius)°C. Feels Like: \(tempFeelLikeCelsius)°C"
        self.iconName = iconName
        self.tempCelsius = tempCelsius
        super.init()
    }
}

struct LocationItem {
    let location: CLLocation
    let title: String
    let description: String
    let iconName: String
}
