//
//  Weather_AppTests.swift
//  Weather AppTests
//
//  Created by William West on 8/20/24.
//

import XCTest
import CoreLocation
@testable import Weather_App

class MockLocationManager: CLLocationManager {
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var mockLocation: CLLocation?
    
    override var authorizationStatus: CLAuthorizationStatus {
        return mockAuthorizationStatus
    }
    
    override var location: CLLocation? {
        return mockLocation
    }
}

class MockGeocoder: CLGeocoder {
    var mockPlacemark: CLPlacemark!
    
    override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        completionHandler([mockPlacemark], nil)
    }
}

final class Weather_AppTests: XCTestCase {
    
    var viewModel: WeatherViewModel!
    var mockLocationManager: MockLocationManager!
    var mockGeocoder: MockGeocoder!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockLocationManager = MockLocationManager()
        mockGeocoder = MockGeocoder()
        viewModel = WeatherViewModel(locationManager: mockLocationManager, geocoder: mockGeocoder)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        mockLocationManager = nil
        mockGeocoder = nil
        try super.tearDownWithError()
    }
    
    func testHandleSearch_NewLocation() {
        let location = Location(lat: 37.7488, lon: -84.3877, name: "Atlanta")
        viewModel.handleSearch(.new(location))
        
        XCTAssertFalse(viewModel.useLocation)
        XCTAssertEqual(viewModel.coords?.lat, location.lat)
        XCTAssertEqual(viewModel.city, location.name)
    }
    
    func testHandleSearch_UseLocation() {
        viewModel.handleSearch(.useLocation)
        
        XCTAssertTrue(viewModel.useLocation)
    }
    
    func testLoadlastCity_Success() {
        let location = Location(lat: 37.7488, lon: -84.3877, name: "Atlanta")
        let data = try! JSONEncoder().encode(location)
        UserDefaults.standard.set(data, forKey: "location")
        
        viewModel.loadLastCity {
            XCTFail("Load last city failed")
        }
        
        XCTAssertEqual(viewModel.coords!.lat, location.lat)
        XCTAssertEqual(viewModel.city, location.name)
    }
    
    func testLoadLastCity_Failure() {
        UserDefaults.standard.removeObject(forKey: "location")
        
        let expectation = self.expectation(description: "Failure handler called")
        
        viewModel.loadLastCity {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertNil(viewModel.coords)
        XCTAssertEqual(viewModel.city, "Unknown")
    }
    
    func testLocationManagerAuthorizationStatus_AuthorizedWhenInUse() {
        
        mockLocationManager.mockAuthorizationStatus = .authorizedWhenInUse
        viewModel.locationManager(mockLocationManager, didChangeAuthorization: .authorizedWhenInUse)
        
        XCTAssertTrue(viewModel.useLocation)
        XCTAssertTrue(viewModel.needsRefresh)
    }
    
    func testLocationManagerDidUpdateLocations() {
        let location = CLLocation(latitude: 37.7488, longitude: -84.3877)
        
        mockLocationManager.mockLocation = location
        
        viewModel.locationManager(mockLocationManager, didUpdateLocations: [location])
        
        viewModel.useLocation = true
        
        XCTAssertEqual(viewModel.coords?.lat, Decimal(location.coordinate.latitude))
        XCTAssertEqual(viewModel.coords?.lon, Decimal(location.coordinate.longitude))
        
    }
}
