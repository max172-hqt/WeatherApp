//
//  WeatherAPIHelper.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import Foundation

class WeatherAPIWrapper {
    let baseUrl = "https://api.weatherapi.com"
    let key = "Your own key"
    
    // Get current weather and weather forecast at a location
    public func getWeatherForecastAt(
        location: String?,
        handler: @escaping (WeatherResponse) -> Void
    ) {
        guard let location = location else {
            return;
        }
        let url = getForecastURL(query: location)
        getData(url: url, handler: handler)
    }
    
    // Get data from an url
    private func getData(url: URL?, handler: @escaping (WeatherResponse) -> Void) {
        let session = URLSession.shared
        
        if let url {
            let dataTask = session.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    print("Received error")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                if let weatherResponse = self.parseJson(data: data) {
                    handler(weatherResponse)
                } else {
                    print("error")
                }
            }
            
            dataTask.resume()
        }
    }
    
    // Get url for forecast
    private func getForecastURL(query: String) -> URL? {
        let currentEndpoint = "v1/forecast.json"
        let query = "q=\(query)"
        
        guard let url = "\(baseUrl)/\(currentEndpoint)?\(key)&\(query)&days=7"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
    }

    // Parse WeatherResponse json data
    private func parseJson(data: Data) -> WeatherResponse? {
        let decoder = JSONDecoder()
        var response: WeatherResponse?
        
        do {
            try response = decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print(error)
        }
        
        return response
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
    let forecast: Forecast?
    
    // - MARK: Computed properties for common infomation
    var locationName: String {
        return location.name
    }
    
    var conditionText: String {
        return current.condition.text
    }
    
    var conditionIconName: String {
        return current.condition.iconName
    }
    
    var tempCelsius: Double {
        return current.temp_c
    }
    
    var tempFeelLikeCelsius: Double {
        return current.feelslike_c
    }
    
    var highCelsius: Double? {
        if let dayForecast = forecast?.forecastday.first {
            return dayForecast.day.maxtemp_c
        }
        return nil
    }
    
    var lowCelsius: Double? {
        if let dayForecast = forecast?.forecastday.first {
            return dayForecast.day.mintemp_c
        }
        return nil
    }
}

struct Location: Decodable {
    let name: String
    let region: String
    let lat: Double
    let lon: Double
}

struct Weather: Decodable {
    let temp_c: Double
    let temp_f: Double
    let condition: Condition
    let feelslike_c: Double
}

struct Condition: Decodable {
    let code: Int
    let text: String
    
    var iconName: String {
        switch code {
        case 1000:
            return "sun.max"
        case 1003:
            return "cloud.sun"
        case 1006:
            return "cloud.moon"
        case 1009:
            return "cloud"
        case 1030, 1135, 1147:
            return "cloud.fog"
        case 1063:
            return "cloud.sun.rain"
        case 1150...1201:
            return "cloud.rain"
        case 1066, 1069, 1204, 1207...1225:
            return "cloud.sleet"
        case 1072:
            return "cloud.drizzle"
        case 1087:
            return "cloud.bolt"
        case 1114, 1117, 1237...1261:
            return "cloud.snow"
        case 1273...1283:
            return "cloud.bolt.rain"
        default:
            print("missing", code, text)
            return "sun.max"
        }
    }
}

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let day: Day
}

struct Day: Decodable {
    let avgtemp_c: Double
    let condition: Condition
    let maxtemp_c: Double
    let mintemp_c: Double
}
