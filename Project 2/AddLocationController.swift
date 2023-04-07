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
    var locationName: String?
    var location: CLLocation?
    var temperature: Double?
    var lowTemperature: Double?
    var highTemperature: Double?
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
            DispatchQueue.main.async {
                self.weatherResponse = weatherResponse
                self.temperatureLabel.text = "\(weatherResponse.current.temp_c)°C"
                self.locationLabel.text = weatherResponse.location.name
                self.weatherConditionImage.image = UIImage(systemName: weatherResponse.current.condition.getIcon())
                self.locationName = weatherResponse.location.name
                self.location = CLLocation(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon)
                self.temperature = weatherResponse.current.temp_c
                if let currentDayForecast = weatherResponse.forecast?.forecastday.first {
                    self.lowTemperature = currentDayForecast.day.mintemp_c
                    self.highTemperature = currentDayForecast.day.maxtemp_c
                }
            }
        }
    }
}
