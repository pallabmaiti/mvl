//
//  Location.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import CoreLocation
import Foundation

nonisolated struct Location: Equatable, Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let aqi: Int
    let nickname: String?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init(id: UUID, name: String, latitude: Double, longitude: Double, aqi: Int, nickname: String?) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.aqi = aqi
        self.nickname = nickname
    }
    
    static let sampleData = Location(id: .init(), name: "Sample Location", latitude: 12.9629, longitude: 77.5775, aqi: 162, nickname: "My Home")
}
