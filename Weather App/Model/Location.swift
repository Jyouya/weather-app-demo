//
//  Location.swift
//  Weather App
//
//  Created by William West on 8/21/24.
//

import Foundation

public struct Location: Codable {
    let name: String
    let localNames: [String: String]
    let lat: Decimal
    let lon: Decimal
    let country: String // Two letter country code ISO 3166
    let state: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }
    
    init(lat: Decimal, lon: Decimal, name: String) {
        self.lat = lat
        self.lon = lon
        self.name = name
        self.localNames = [:]
        self.country = ""
        self.state = nil
    }
}
