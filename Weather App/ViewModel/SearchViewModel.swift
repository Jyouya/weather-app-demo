//
//  SearchViewModel.swift
//  Weather App
//
//  Created by William West on 8/22/24.
//

import Foundation

extension Notification.Name {
    static let searchResults = Notification.Name("search_results")
}

// View can finish 3 different ways
// user selects a location
// user exits without selecting a location
// user chooses to use location services
public enum SearchViewResult {
    case new(Location)
    case back
    case useLocation
}

class SearchViewModel {
    private let completion: (SearchViewResult) -> Void
    public let locationAvailable: Bool
    
    // This is how we will send our selection back to the WeatherViewModel.  A coordinator would be better if we needed to manage more than two views.
    init(locationAvailable: Bool, completion: @escaping (SearchViewResult) -> Void) {
        self.locationAvailable = locationAvailable
        self.completion = completion
    }
    
    public let searchResultsPublisher = NotificationCenter.Publisher(center: .default, name: .searchResults).map { (notification) -> [Location]? in
        return notification.object as? [Location]
    }
    
    public func search(query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == "" {
            return
        }
        
        LocationRequest.send(query: trimmed) { result in
            switch(result) {
            case .failure:
                return;
            case .success(let locationResponse):
                let locations = locationResponse as [Location]
                NotificationCenter.default.post(name: .searchResults, object: locations)
            }
        }
    }
    
    // We're trusting the viewcontroller to actually backwards navigate in these 3 cases.  Ideally, a coordinator would handle navigation.
    public func back() {
        completion(.back)
    }
    
    public func useLocation() {
        completion(.useLocation)
    }
    
    public func choose(location: Location) {
        // TODO: Add city and coords to user defaults
        completion(.new(location))
    }
}
