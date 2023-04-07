//
//  AddLocationController.swift
//  Project 2
//
//  Created by Huy Tran on 4/7/23.
//

import UIKit
import MapKit

class AddLocationController: UIViewController {
    let api = WeatherAPIWrapper()
    var location: CLLocation?
    var weatherResponse: WeatherResponse?
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func onCancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func onSearchButtonTapped(_ sender: UIButton) {
        let location = searchTextField.text
        api.getWeatherForecastAt(location: location) { weatherResponse in
            self.location = CLLocation(
                latitude: weatherResponse.location.lat,
                longitude: weatherResponse.location.lon
            )
            self.weatherResponse = weatherResponse
            
            DispatchQueue.main.async {
                self.temperatureLabel.text = "\(weatherResponse.current.temp_c)\(CELSIUS_UNIT)"
                self.locationLabel.text = weatherResponse.location.name
                self.weatherConditionImage.image = UIImage(systemName: weatherResponse.conditionIconName)
            }
        }
    }
}
