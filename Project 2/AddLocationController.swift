//
//  AddLocationController.swift
//  Project 2
//
//  Created by Huy Tran on 4/7/23.
//

import UIKit
import MapKit

class AddLocationController: UIViewController, UITextFieldDelegate {
    let api = WeatherAPIWrapper()
    var location: CLLocation?
    var weatherResponse: WeatherResponse?
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
    }
    
    @IBAction func onCancelButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func onSearchButtonTapped(_ sender: UIButton) {
        updateWeather()
    }
    
    // - MARK: Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        updateWeather()
        return true
    }
    
    // Update weather information for the current location in text field
    private func updateWeather() {
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
