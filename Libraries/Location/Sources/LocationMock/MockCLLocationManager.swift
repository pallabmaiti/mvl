//
//  MockCLLocationManager.swift
//  Location
//
//  Created by Pallab Maiti on 14/04/26.
//

import CoreLocation

public class MockCLLocationManager: CLLocationManager {
    public var mockDelegate: CLLocationManagerDelegate?
    public var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    public var mockLocation: CLLocation?
    public var didRequestWhenInUseAuthorization: Bool = false
    public var didRequestAlwaysAuthorization: Bool = false
    public var didStartUpdatingLocation: Bool = false
    public var didStopUpdatingLocation: Bool = false
    
    override public var delegate: CLLocationManagerDelegate? {
        get { mockDelegate }
        set { mockDelegate = newValue }
    }
    
    public override var authorizationStatus: CLAuthorizationStatus { mockAuthorizationStatus }
    
    public override var location: CLLocation? { mockLocation }
    
    public override func requestWhenInUseAuthorization() {
        didRequestWhenInUseAuthorization = true
        mockDelegate?.locationManagerDidChangeAuthorization?(self)
    }
    
    public override func requestAlwaysAuthorization() {
        didRequestAlwaysAuthorization = true
        mockDelegate?.locationManagerDidChangeAuthorization?(self)
    }

    public override func startUpdatingLocation() {
        didStartUpdatingLocation = true
    }

    public override func stopUpdatingLocation() {
        didStopUpdatingLocation = true
    }
}
