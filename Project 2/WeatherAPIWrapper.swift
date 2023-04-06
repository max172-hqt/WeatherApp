//
//  WeatherAPIHelper.swift
//  Project 2
//
//  Created by Huy Tran on 4/6/23.
//

import Foundation

class WeatherAPIWrapper {
    public func getWeatherAt(
        location: String?,
        handler: @escaping (WeatherResponse) -> Void
    ) {
        guard let location = location else {
            return;
        }
        
        let url = getURL(query: location)
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
                }
            }
            
            dataTask.resume()
        }
    }
    
    private func getURL(query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com"
        let currentEndpoint = "v1/current.json"
        let key = "key=e462f21382704519b8f175150231603"
        let query = "q=\(query)"
        
        guard let url = "\(baseUrl)/\(currentEndpoint)?\(key)&\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        
        return URL(string: url)
    }

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
}

struct Location: Decodable {
    let name: String
    let region: String
}

struct Weather: Decodable {
    let temp_c: Double
    let temp_f: Double
    let condition: Condition
}

struct Condition: Decodable {
    let code: Int
}
