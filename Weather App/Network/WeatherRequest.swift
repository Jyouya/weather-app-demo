//
//  WeatherRequest.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation

struct WeatherRequest {
//    api.openweathermap.org/data/2.5/forecast?lat=44.34&lon=10.99&appid={API key}
    static private let scheme = "https"
    static private let host = "api.openweathermap.org"
    static private let path = "/data/2.5/forecast"
    
    static private func buildURL(coords: GPSCoord) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "lat", value: coords.lat.description),
            URLQueryItem(name: "lon", value: coords.lon.description),
            URLQueryItem(name: "appid", value: APIKey.key)
        ]
        
        return components.url
    }
    		
    static func send(coords: GPSCoord, completion: @escaping (Result<WeatherResponse, NetworkError>) -> Void) {
        guard let url = buildURL(coords: coords) else {
            completion(.failure(.urlError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in

            guard let data = data else {
                completion(.failure(.networkError))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            guard let response = try? jsonDecoder.decode(WeatherResponse.self, from: data) else {
                completion(.failure(.decodingError))
                return
            }
            
            completion(.success(response))
        }.resume()
    }
}
