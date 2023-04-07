//
//  WeatherAPIHelper.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import Foundation

class WeatherAPIWrapper {
    let baseUrl = "https://api.weatherapi.com"
    let key = "key=e462f21382704519b8f175150231603"
    
    // Get current weather at a location
    public func getWeatherAt(
        location: String?,
        handler: @escaping (WeatherResponse) -> Void
    ) {
        guard let location = location else {
            return;
        }
        let url = getCurrentURL(query: location)
        getData(url: url, handler: handler)
    }
    
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
    
    // Get url for the current weather
    private func getCurrentURL(query: String) -> URL? {
        let currentEndpoint = "v1/current.json"
        let query = "q=\(query)"
        
        guard let url = "\(baseUrl)/\(currentEndpoint)?\(key)&\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
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
}

struct Location: Decodable {
    let name: String
    let region: String
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
    
    func getIcon() -> String {
        switch code {
        case 1000:
            return "sun.max"
        case 1003...1030:
            return "cloud"
        case 1180...1201:
            return "cloud.rain"
        case 1210...1225:
            return "cloud.snow"
        case 1273...1283:
            return "cloud.bolt.rain"
        default:
            return ""
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
}
