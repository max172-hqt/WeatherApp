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
        // Do any additional setup after loading the view.
        if let locValue = currentCoordinate {
            let locationString =  "\(locValue.latitude),\(locValue.longitude)"
            api.getWeatherForecastAt(location: locationString) { weatherResponse in
                self.forecastItems = weatherResponse.forecast?.forecastday ?? []
                DispatchQueue.main.async {
                    self.locationLabel.text = weatherResponse.location.name
                    self.weatherConditionImage.image = UIImage(systemName: weatherResponse.current.condition.getIcon())
                    self.weatherConditionLabel.text = weatherResponse.current.condition.text
                    self.currentTemperature.text = "\(weatherResponse.current.temp_c)°C"
                    self.lowTemperature.text = "Low: \(weatherResponse.forecast?.forecastday[0].day.mintemp_c ?? 0)°C"
                    self.highTemperature.text = "High: \(weatherResponse.forecast?.forecastday[0].day.maxtemp_c ?? 0)°C"
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
        content.secondaryText = "\(item.day.avgtemp_c)°C"
        content.prefersSideBySideTextAndSecondaryText = true
        content.secondaryTextProperties.font = content.textProperties.font
        content.image = UIImage(systemName: item.day.condition.getIcon())
        
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
