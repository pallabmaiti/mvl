//
//  LocationServiceImpl.swift
//  Location
//
//  Created by Pallab Maiti on 14/04/26.
//

import Combine
import CoreLocation

public final class LocationServiceImpl: NSObject, LocationService {
    public let locationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    
    private let manager: CLLocationManager
    
    public init(manager: CLLocationManager = CLLocationManager()) {
        self.manager = manager
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    public var location: CLLocation? {
        manager.location
    }
    
    public var authorizationStatus: CLAuthorizationStatus {
        manager.authorizationStatus
    }

    public var isAuthorized: Bool {
        [CLAuthorizationStatus.authorizedAlways, CLAuthorizationStatus.authorizedWhenInUse].contains(authorizationStatus)
    }

    public func requestAlwaysAuthorization() {
        manager.requestAlwaysAuthorization()
    }
    
    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    public func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }
}

extension LocationServiceImpl: CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if isAuthorized {
            startUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationSubject.send(locations.last)
    }
}
