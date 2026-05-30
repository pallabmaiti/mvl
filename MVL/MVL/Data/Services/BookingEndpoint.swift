//
//  BookingEndpoint.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation
import Networking

struct BookingEndpoint: ServiceEndpoint {
    struct Body: Encodable {
        struct Location: Encodable {
            let id: UUID
            let latitude: Double
            let longitude: Double
            let aqi: Int
            let name: String
        }
        let a: Location
        let b: Location
    }
    typealias SuccessResponse = BookingResponse
    typealias FailureResponse = GenericResponseError
    
    let body: Body?
    let method: RequestMethod = .post
    let baseURL: String = ""
    let path: String
    
    init(locationA: Location, locationB: Location) {
        path = Endpoint.book.path
        body = Body(
            a: Body.Location(
                id: UUID(),
                latitude: locationA.latitude,
                longitude: locationA.longitude,
                aqi: locationA.aqi,
                name: locationA.name
            ),
            b: Body.Location(
                id: UUID(),
                latitude: locationB.latitude,
                longitude: locationB.longitude,
                aqi: locationB.aqi,
                name: locationB.name
            )
        )
    }
}

nonisolated struct BookingResponse: Decodable, Sendable {
    struct Location: Decodable, Sendable {
        let id: UUID
        let latitude: Double
        let longitude: Double
        let aqi: Int
        let name: String
    }
    let id: UUID
    let a: Location
    let b: Location
    let price: Double
    
    static let sampleData = BookingResponse(id: UUID(), a: Location(id: UUID(), latitude: 12.9629, longitude: 77.5775, aqi: 162, name: "Bangalore"), b: Location(id: UUID(), latitude: 12.9635, longitude: 77.5789, aqi: 200, name: "Mangalore"), price: 5000)
}
