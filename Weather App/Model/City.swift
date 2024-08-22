//
//  City.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation

struct City: Decodable {
    let id: Int
    let name: String
    let coord: GPSCoord
    let country: String // Two letter country code ISO 3166
    let population: Int
    let timezone: Int
    let sunrise: TimeInterval
    let sunset: TimeInterval
}

