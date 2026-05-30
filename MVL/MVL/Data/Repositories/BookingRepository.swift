//
//  BookingRepository.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Networking
import NetworkingMock

protocol BookingRepository {
    func book(locationA: Location, locationB: Location) async throws -> BookingResponse
}

final class BookingRepositoryImpl: BookingRepository {
    private let networking: Networking
    
    init() {
        self.networking = .mock(responseHandler: { endpoint throws(NetworkError) -> Any in
            switch endpoint {
            case is BookingEndpoint:
                return BookingResponse.sampleData
            default:
                throw NetworkError.missingStubbedResponse
            }
        })
    }

    func book(locationA: Location, locationB: Location) async throws -> BookingResponse {
        let endpoint = BookingEndpoint(locationA: locationA, locationB: locationB)
        return try await networking.fetch(endpoint)
    }
}

final class MockBookingRepositoryImpl: BookingRepository {
    let result: Result<BookingResponse, Error>
    
    init(result: Result<BookingResponse, Error>) {
        self.result = result
    }
    
    func book(locationA: Location, locationB: Location) async throws -> BookingResponse {
        switch result {
        case .success(let response):
            return response
        case .failure(let failure):
            throw failure
        }
    }
}
