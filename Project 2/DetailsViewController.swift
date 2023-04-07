//
//  DetailsViewController.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import UIKit
import MapKit

class DetailsViewController: UIViewController {
    var currentCoordinate: CLLocationCoordinate2D?
    var forecastItems: [ForecastDay] = []
    let api = WeatherAPIWrapper()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var highTemperature: UILabel!
    @IBOutlet weak var lowTemperature: UILabel!
    @IBOutlet weak var currentTemperature: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        if let locValue = currentCoordinate {
            let locationString =  "\(locValue.latitude),\(locValue.longitude)"
            api.getWeatherForecastAt(location: locationString) { weatherResponse in
                self.forecastItems = weatherResponse.forecast?.forecastday ?? []
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.locationName
                    self.weatherConditionImage.image = UIImage(systemName: weatherResponse.conditionIconName)
                    self.weatherConditionLabel.text = weatherResponse.conditionText
                    self.currentTemperature.text = "\(weatherResponse.tempCelsius)\(CELSIUS_UNIT)"
                    self.lowTemperature.text = "Low: \(weatherResponse.lowCelsius ?? 0)\(CELSIUS_UNIT)"
                    self.highTemperature.text = "High: \(weatherResponse.highCelsius ?? 0)\(CELSIUS_UNIT)"
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        let item = forecastItems[indexPath.row]
        
        let index = Calendar.current.component(.weekday, from: getDate(from: item.date)!)
        content.text = Calendar.current.weekdaySymbols[index - 1]
        content.secondaryText = "\(item.day.avgtemp_c)\(CELSIUS_UNIT)"
        content.prefersSideBySideTextAndSecondaryText = true
        content.secondaryTextProperties.font = content.textProperties.font
        content.image = UIImage(systemName: item.day.condition.iconName)
        
        cell.contentConfiguration = content
        
        return cell
    }
}

func getDate(from date: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.locale = Locale.current
    return dateFormatter.date(from: date)
}
