//
//  GPSCoord.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation
import CoreLocation

struct GPSCoord: Decodable {
    init(coordinate: CLLocationCoordinate2D) {
        lat = Decimal(coordinate.latitude)
        lon = Decimal(coordinate.longitude)
    }
    init(lat: Decimal, lon: Decimal) {
        self.lat = lat
        self.lon = lon
    }
    let lat: Decimal
    let lon: Decimal
}
