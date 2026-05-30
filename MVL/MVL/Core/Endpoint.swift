//
//  Endpoint.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Foundation

public enum Endpoint {
    case aqiData(latitude: Double, longitude: Double)
    case reverseGeocode
    case book
    case bookingList
    
    var path: String {
        switch self {
        case .aqiData(let latitude, let longitude):
            return "/feed/geo:\(latitude);\(longitude)/"
        case .reverseGeocode:
            return "/reverse-geocode"
        case .book:
            return "/book"
        case .bookingList:
            return "/books"
        }
    }
}
