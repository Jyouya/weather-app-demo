//
//  WeatherEntry.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation

struct WeatherEntry: Decodable {
    let timestamp: TimeInterval
    
    let main: WeatherMain
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind

    let visibility: Int
    let pop: Decimal
    let sys: WeatherSys
    let dateString: String
    
    private enum CodingKeys: String, CodingKey {
        case timestamp = "dt"
        case main
        case weather
        case clouds
        case wind
        case visibility
        case pop
        case sys
        case dateString = "dt_txt"
    }
}

struct WeatherSys: Decodable {
    let pod: String
}

struct WeatherMain: Decodable {
    let temp: Decimal
    let feelsLike: Decimal
    let tempMin: Decimal
    let tempMax: Decimal
    let pressure: Int
    let seaLevel: Int
    let grndLevel: Int
    let humidity: Int
    let tempKf: Decimal
    
    private enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
    }
}
