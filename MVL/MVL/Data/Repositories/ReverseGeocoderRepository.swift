//
//  ReverseGeocoderRepository.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Networking

protocol ReverseGeocoderRepository {
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> ReverseGeocodeResponse
}

final class ReverseGeocoderRepositoryImpl: ReverseGeocoderRepository {
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> ReverseGeocodeResponse {
        let endpoint = ReverseGeocodeEndpoint(latitude: latitude, longitude: longitude)
        return try await networking.fetch(endpoint)
    }
}


final class MockReverseGeocoderRepositoryImpl: ReverseGeocoderRepository {
    let result: Result<ReverseGeocodeResponse, Error>
    
    init(response: Result<ReverseGeocodeResponse, Error>) {
        self.result = response
    }
    
    func reverseGeocode(latitude: Double, longitude: Double) async throws -> ReverseGeocodeResponse {
        switch result {
        case .success(let response):
            return response
        case .failure(let failure):
            throw failure
        }
    }
}
