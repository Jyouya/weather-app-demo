//
//  WeatherViewModel.swift
//  Weather App
//
//  Created by William West on 8/21/24.
//

import Foundation
import CoreLocation
// flow: land on weather page if location is stored, or location is allowed
// - land on search page if location is not allowed and not stored

extension Notification.Name {
    static let cityUpdate = Notification.Name("city_update")
    static let weatherUpdate = Notification.Name("weather_update")
}

class WeatherViewModel:  NSObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    private var weather: [WeatherEntry]?
    
    private var locCoords: GPSCoord?
    private var locCity: String?
    
    private var storedCoords: GPSCoord?
    private var storedCity: String?
    
    public var coords: GPSCoord? {
        get { useLocation ? locCoords : storedCoords }
    }
    
    public var city: String {
        get { (useLocation ? locCity : storedCity ) ?? "Unknown"}
    }
    
    public var useLocation = false
    public var needsRefresh = false
    
    public var locationAvailable: Bool {
        get {
            switch(locationManager.authorizationStatus) {
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            default:
                return false
            }
        }
    }
    
    public let cityPublisher = NotificationCenter.Publisher(center: .default, name: .cityUpdate, object: nil)
        .map { (notification) -> String? in
            return notification.object as? String
        }
    
    public let weatherPublisher = NotificationCenter.Publisher(center: .default, name: .weatherUpdate, object: nil)
        .map { (notification) -> [Date: [WeatherEntry]]? in
            // Would like to use an ordered dictionary here
            let calendar = Calendar.current
            
            var groupedEntries = [Date: [WeatherEntry]]()
            
            guard let entries = (notification.object as? WeatherResponse)?.list else { return nil }
            
            for entry in entries {
                let date = Date(timeIntervalSince1970: entry.timestamp)
                let startOfDay = calendar.startOfDay(for: date)
                
                if groupedEntries[startOfDay] != nil {
                    groupedEntries[startOfDay]?.append(entry)
                } else {
                    groupedEntries[startOfDay] = [entry]
                }
            }
            
            return groupedEntries
        }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Allow injection of managers for unit testing
    init(locationManager: CLLocationManager, geocoder: CLGeocoder) {
        super.init()
        self.locationManager = locationManager
        self.geocoder = geocoder
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func handleSearch(_ result: SearchViewResult) {
        switch(result) {
        case .new(let location):
            useLocation = false
            storedCoords = GPSCoord(lat: location.lat, lon: location.lon)
            storedCity = location.name
            
            if let encodedLocation = try? JSONEncoder().encode(location) {
                UserDefaults.standard.set(encodedLocation, forKey: "location")
            }
            
            loadCoords()
        case .useLocation:
            useLocation = true
            loadCoords()
            
        case .back:
            return
        }
    }
    
    func loadLastCity(onFailure: (()->())? = nil) {
        if let data = UserDefaults.standard.data(forKey: "location") {
            let decoder = JSONDecoder()
            if let location = try? decoder.decode(Location.self, from: data) {
                self.storedCoords = GPSCoord(lat: location.lat, lon: location.lon)
                self.storedCity = location.name
                loadCoords()
                return
            }
        }
        onFailure?()
    }
    
    func loadCoords() {
        guard let coords = coords else {
            return
        }
        
        needsRefresh = false
        
        WeatherRequest.send(coords: coords) { result in
            switch(result) {
            case .failure:
                // TODO: Error handling
                return
            case .success(let weatherResponse):
                NotificationCenter.default.post(name: .weatherUpdate, object: weatherResponse)
                break
            }
        }
        
        if useLocation {
            if let location = locationManager.location {
                geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
                    // We don't need to handle the error, since city will show up as "Unknown" if placemarks is null
                    guard let self = self else { return }
                    self.locCity = placemarks?.first?.locality
                    NotificationCenter.default.post(name: .cityUpdate, object: self.city)
                }
            }
        } else {
            NotificationCenter.default.post(name: .cityUpdate, object: self.city)
        }
        
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Not sure if it's possible for locations to be length 0, but best to be safe
        guard let location = locations.last else { return }
        self.locCoords = GPSCoord(coordinate: location.coordinate)
        if (needsRefresh) {
            loadCoords()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            useLocation = true
            needsRefresh = true
            locationManager.startUpdatingLocation()
        case .notDetermined:
            useLocation = false
            loadLastCity() // No failure handler, because we don't want to navigate to search unless the user denies permission
        default:
            useLocation = false
            loadLastCity() {
                //TODO: Navigate to search page
            }
        }
    }
}
