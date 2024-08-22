//
//  LocationRequest.swift
//  Weather App
//
//  Created by William West on 8/21/24.
//

import Foundation

struct LocationRequest {
    static private let scheme = "https"
    static private let host = "api.openweathermap.org"
    static private let path = "/geo/1.0/direct"
    
    static private func buildURL(query: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "appid", value: APIKey.key)
        ]
        
        return components.url
    }
    
    static func send(query: String, completion: @escaping (Result<LocationResponse, NetworkError>) -> Void) {
        
        guard let url = buildURL(query: query) else {
            completion(.failure(.urlError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(.failure(.networkError))
                return
            }
            
            let jsonDecoder = JSONDecoder()
            
            guard let response = try? jsonDecoder.decode(LocationResponse.self, from: data) else {
                completion(.failure(.decodingError))
                return
            }
            
            completion(.success(response))
        }.resume()
    }
}
