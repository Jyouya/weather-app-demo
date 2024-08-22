//
//  IconRequest.swift
//  Weather App
//
//  Created by William West on 8/21/24.
//

import Foundation
import UIKit

// I would implement cacheing here if needed
struct IconRequest {
    static private let scheme = "https"
    static private let host = "openweathermap.org"
    
    static private func buildURL(icon: String, size: Int) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/img/wn/\(icon)\(size > 1 ? "@\(size)x" : "").png"
        
        return components.url
    }
    
    static func send(icon: String, size: Int = 1, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        guard let url = buildURL(icon: icon, size: size) else {
            completion(.failure(.urlError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                completion(.failure(.networkError))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(.decodingError))
                return
            }
            
            completion(.success(image))
        }.resume()
    }
}
