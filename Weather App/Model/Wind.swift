//
//  Wind.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation

struct Wind: Decodable {
    let speed: Decimal
    let deg: Int
    let gust: Decimal
}
