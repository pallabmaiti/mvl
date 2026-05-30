//
//  AqiDataEndpoint.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Networking

struct AqiDataEndpoint: ServiceEndpoint {
    struct Body: Encodable {
        let token: String
    }
    typealias SuccessResponse = AqiDataResponse
    typealias FailureResponse = AqiDataFailureResponse
    
    let body: Body?
    let method: RequestMethod = .get
    let baseURL: String = "https://api.waqi.info"
    let path: String
    
    init(latitude: Double, longitude: Double) {
        path = Endpoint.aqiData(latitude: latitude, longitude: longitude).path
        body = Body(token: AppConfiguration.aqiApiToken)
    }
}

nonisolated struct AqiDataFailureResponse: Decodable & Sendable {
    let status: String
    let message: String
}

nonisolated struct AqiDataResponse: Decodable & Sendable {
    struct AqiData: Decodable, Sendable {
        struct City: Decodable, Sendable {
            let name: String
        }
        let aqi: Int
        let id: Int
        let city: City
        
        enum CodingKeys: String, CodingKey {
            case aqi
            case id = "idx"
            case city
        }
    }
    let status: String
    let data: AqiData
    
    static let sampleData = AqiDataResponse(status: "ok", data: AqiData(aqi: 162, id: 1, city: AqiData.City(name: "Bangalore")))
}
