//
//  NetworkError.swift
//  Weather App
//
//  Created by William West on 8/21/24.
//

import Foundation

enum NetworkError: Error {
    case urlError
    case networkError
    case decodingError
}
