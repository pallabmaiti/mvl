//
//  LocationServiceTests.swift
//  Location
//
//  Created by Pallab Maiti on 14/04/26.
//

@testable import Location
import CoreLocation
import LocationMock
import XCTest

final class LocationServiceTests: XCTestCase {
    func testInitSetsDelegateAndDesiredAccuracy() {
        let manager = MockCLLocationManager()

        let service = LocationServiceImpl(manager: manager)

        XCTAssertTrue(manager.delegate === service)
        XCTAssertEqual(manager.desiredAccuracy, kCLLocationAccuracyBest)
    }

    func testLocationReturnsManagersLocation() {
        let manager = MockCLLocationManager()
        let expectedLocation = CLLocation(latitude: 12.9629, longitude: 77.5775)
        manager.mockLocation = expectedLocation

        let service = LocationServiceImpl(manager: manager)

        XCTAssertEqual(service.location, expectedLocation)
    }

    func testAuthorizationStatusReturnsManagersStatus() {
        let manager = MockCLLocationManager()
        manager.mockAuthorizationStatus = .authorizedWhenInUse

        let service = LocationServiceImpl(manager: manager)

        XCTAssertEqual(service.authorizationStatus, .authorizedWhenInUse)
    }

    func testIsAuthorizedIsTrueForAuthorizedAlways() {
        let manager = MockCLLocationManager()
        manager.mockAuthorizationStatus = .authorizedAlways

        let service = LocationServiceImpl(manager: manager)

        XCTAssertTrue(service.isAuthorized)
    }

    func testIsAuthorizedIsTrueForAuthorizedWhenInUse() {
        let manager = MockCLLocationManager()
        manager.mockAuthorizationStatus = .authorizedWhenInUse

        let service = LocationServiceImpl(manager: manager)

        XCTAssertTrue(service.isAuthorized)
    }

    func testIsAuthorizedIsFalseForDeniedStatus() {
        let manager = MockCLLocationManager()
        manager.mockAuthorizationStatus = .denied

        let service = LocationServiceImpl(manager: manager)

        XCTAssertFalse(service.isAuthorized)
    }

    func testRequestWhenInUseAuthorizationForwardsToManager() {
        let manager = MockCLLocationManager()
        let service = LocationServiceImpl(manager: manager)

        service.requestWhenInUseAuthorization()

        XCTAssertTrue(manager.didRequestWhenInUseAuthorization)
    }

    func testRequestAlwaysAuthorizationForwardsToManager() {
        let manager = MockCLLocationManager()
        let service = LocationServiceImpl(manager: manager)

        service.requestAlwaysAuthorization()

        XCTAssertTrue(manager.didRequestAlwaysAuthorization)
    }

    func testStartUpdatingLocationForwardsToManager() {
        let manager = MockCLLocationManager()
        let service = LocationServiceImpl(manager: manager)

        service.startUpdatingLocation()

        XCTAssertTrue(manager.didStartUpdatingLocation)
    }

    func testStopUpdatingLocationForwardsToManager() {
        let manager = MockCLLocationManager()
        let service = LocationServiceImpl(manager: manager)

        service.stopUpdatingLocation()

        XCTAssertTrue(manager.didStopUpdatingLocation)
    }

    func testLocationManagerDidChangeAuthorizationStartsUpdatesWhenAuthorized() {
        let manager = MockCLLocationManager()
        manager.mockAuthorizationStatus = .authorizedWhenInUse
        let service = LocationServiceImpl(manager: manager)

        service.locationManagerDidChangeAuthorization(manager)

        XCTAssertTrue(manager.didStartUpdatingLocation)
    }

    func testLocationManagerDidChangeAuthorizationDoesNotStartUpdatesWhenUnauthorized() {
        let manager = MockCLLocationManager()
        manager.mockAuthorizationStatus = .restricted
        let service = LocationServiceImpl(manager: manager)

        service.locationManagerDidChangeAuthorization(manager)

        XCTAssertFalse(manager.didStartUpdatingLocation)
    }

    func testDidUpdateLocationsPublishesLastLocation() {
        let manager = MockCLLocationManager()
        let service = LocationServiceImpl(manager: manager)
        let firstLocation = CLLocation(latitude: 10, longitude: 20)
        let lastLocation = CLLocation(latitude: 30, longitude: 40)

        service.locationManager(manager, didUpdateLocations: [firstLocation, lastLocation])

        XCTAssertEqual(service.locationSubject.value, lastLocation)
    }

    func testLocationSubjectStartsWithNilValue() {
        let manager = MockCLLocationManager()
        let service = LocationServiceImpl(manager: manager)

        XCTAssertNil(service.locationSubject.value)
    }
}
