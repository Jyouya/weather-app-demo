//
//  LocalizeTemperature.swift
//  Weather App
//
//  Created by William West on 8/21/24.
//

import Foundation

func localizeTemperature(K: Double) -> Double {
    if Locale.current.measurementSystem == .us {
        return (K - 273.15) * 9/5 + 32
    } else {
        return K - 273.15
    }
}

func formatTemperature(K: Double) -> String {
    let C = K - 273.15
    if Locale.current.measurementSystem == .us {
        return String(format: "%.0f°F", C * 9/5 + 32)
    } else {
        return String(format: "%.0f°C", C)
    }
}

func formatTemperature(K: Decimal, showUnit: Bool = false) -> String {
    let kd = NSDecimalNumber(decimal: K).doubleValue
    let C = kd - 273.15
    
    if Locale.current.measurementSystem == .us {
        let unit = showUnit ? "F" : ""
        return String(format: "%.0f°%@", C * 9/5 + 32, unit)
    } else {
        let unit = showUnit ? "C" : ""
        return String(format: "%.0f°%@", C, unit)
    }
}
