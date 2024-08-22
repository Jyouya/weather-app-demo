//
//  Weather.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation


struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}


