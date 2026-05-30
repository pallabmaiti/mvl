//
//  AqiDataRepository.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Networking

protocol AqiDataRepository {
    func fetchAqiData(latitude: Double, longitude: Double) async throws -> AqiDataResponse
}

final class AqiDataRepositoryImpl: AqiDataRepository {
    private let networking: Networking
    
    init(networking: Networking) {
        self.networking = networking
    }
    
    func fetchAqiData(latitude: Double, longitude: Double) async throws -> AqiDataResponse {
        let endpoint = AqiDataEndpoint(latitude: latitude, longitude: longitude)
        return try await networking.fetch(endpoint)
    }
}

final class MockAqiDataRepositoryImpl: AqiDataRepository {
    let result: Result<AqiDataResponse, Error>
    
    init(result: Result<AqiDataResponse, Error>) {
        self.result = result
    }
    
    func fetchAqiData(latitude: Double, longitude: Double) async throws -> AqiDataResponse {
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
