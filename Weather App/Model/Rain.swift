//
//  Rain.swift
//  Weather App
//
//  Created by William West on 8/20/24.
//

import Foundation

struct Rain: Decodable {
    let threeHour: Decimal
    
    private enum CodingKeys: String, CodingKey {
        case threeHour = "3h"
    }
}
