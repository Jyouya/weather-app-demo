//
//  WeatherResponse.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation

struct WeatherResponse: Decodable {
    let cod: String?
    let message: Int?
    let cnt: Int?
    let list: [WeatherEntry]?
    let city: City?
}
