//
//  LocationService.swift
//  Location
//
//  Created by Pallab Maiti on 14/04/26.
//

import Combine
import CoreLocation

public protocol LocationService {
    var location: CLLocation? { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    var isAuthorized: Bool { get }
    var locationSubject: CurrentValueSubject<CLLocation?, Never> { get }

    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}
