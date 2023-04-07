//
//  AddLocationController.swift
//  Project 2
//
//  Created by Huy Tran on 4/7/23.
//

import UIKit

class AddLocationController: UIViewController {
    let api = WeatherAPIWrapper()
    var locationName: String?
    var latitude: Double?
    var longitude: Double?
    
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
        api.getWeatherAt(location: location) { weatherResponse in
            DispatchQueue.main.async {
                self.temperatureLabel.text = "\(weatherResponse.current.temp_c)°C"
                self.locationLabel.text = weatherResponse.location.name
                self.weatherConditionImage.image = UIImage(systemName: weatherResponse.current.condition.getIcon())
                self.locationName = weatherResponse.location.name
                self.latitude = weatherResponse.location.lat
                self.longitude = weatherResponse.location.lon
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
