//
//  DetailsViewController.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import UIKit

class DetailsViewController: UIViewController {
    let api = WeatherAPIWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        api.getWeatherForecastAt(location: "Hong Kong") { weatherResponse in
            print(weatherResponse)
        }
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
