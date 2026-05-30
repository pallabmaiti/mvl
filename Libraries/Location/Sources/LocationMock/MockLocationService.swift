//
//  MockLocationService.swift
//  Location
//
//  Created by Pallab Maiti on 14/04/26.
//

import Combine
import CoreLocation
import Foundation
import Location

public final class MockLocationService: NSObject, LocationService {
    public let locationSubject: CurrentValueSubject<CLLocation?, Never>
    public var stubAuthorizationStatus: CLAuthorizationStatus
    public var didRequestWhenInUseAuthorization = false
    public var didRequestAlwaysAuthorization = false
    public var didStartUpdatingLocation = false
    public var didStopUpdatingLocation = false

    public init(
        location: CLLocation? = CLLocation(latitude: 12.9629, longitude: 77.5775),
        authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    ) {
        self.locationSubject = CurrentValueSubject(location)
        self.stubAuthorizationStatus = authorizationStatus
    }

    public var location: CLLocation? {
        locationSubject.value
    }

    public var authorizationStatus: CLAuthorizationStatus {
        stubAuthorizationStatus
    }

    public var isAuthorized: Bool {
        [CLAuthorizationStatus.authorizedAlways, CLAuthorizationStatus.authorizedWhenInUse].contains(authorizationStatus)
    }

    public func requestAlwaysAuthorization() {
        didRequestAlwaysAuthorization = true
    }

    public func requestWhenInUseAuthorization() {
        didRequestWhenInUseAuthorization = true
    }

    public func startUpdatingLocation() {
        didStartUpdatingLocation = true
    }

    public func stopUpdatingLocation() {
        didStopUpdatingLocation = true
    }
}
