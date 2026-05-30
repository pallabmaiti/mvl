//
//  ReverseGeocodeEndpoint.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Networking

struct ReverseGeocodeEndpoint: ServiceEndpoint {
    struct Body: Encodable {
        let latitude: Double
        let longitude: Double
        let key: String
        let localityLanguage = "en"
    }
    typealias SuccessResponse = ReverseGeocodeResponse
    typealias FailureResponse = ReverseGeocodeFailureResponse
    
    let body: Body?
    let method: RequestMethod = .get
    let baseURL: String = "https://api-bdc.net/data"
    let path: String
    
    init(latitude: Double, longitude: Double) {
        path = Endpoint.reverseGeocode.path
        body = Body(
            latitude: latitude,
            longitude: longitude,
            key: AppConfiguration.rgApiKey
        )
    }
}

nonisolated struct ReverseGeocodeResponse: Decodable & Sendable {
    struct LocalityInfo: Decodable & Sendable {
        struct Administrative: Decodable & Sendable {
            let order: Int
            let name: String
        }
        let administrative: [Administrative]
    }
    let latitude: Double
    let longitude: Double
    let localityInfo: LocalityInfo
    
    static let sampleData = ReverseGeocodeResponse(
        latitude: 12.9629,
        longitude: 77.5775,
        localityInfo: .init(
            administrative: [
                .init(order: 4, name: "Electronic City"),
                .init(order: 5, name: "Bangalore")
            ]
        )
    )
}

nonisolated struct ReverseGeocodeFailureResponse: Decodable & Sendable {
    let status: Int
    let description: String
}
