//
//  BookingListRepository.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Networking
import NetworkingMock

protocol BookingListRepository {
    func fetchBookingList(year: Int, month: Int) async throws -> [BookingResponse]
}

final class BookingListRepositoryImpl: BookingListRepository {
    private let networking: Networking
    
    init() {
        self.networking = .mock(responseHandler: { endpoint throws(NetworkError) -> Any in
            switch endpoint {
            case is BookingListEndpoint:
                return [BookingResponse.sampleData]
            default:
                throw NetworkError.missingStubbedResponse
            }
        })
    }

    func fetchBookingList(year: Int, month: Int) async throws -> [BookingResponse] {
        let endpoint = BookingListEndpoint(year: year, month: month)
        return try await networking.fetch(endpoint)
    }
}

final class MockBookingListRepositoryImpl: BookingListRepository {
    let result: Result<[BookingResponse], Error>
    
    init(result: Result<[BookingResponse], Error>) {
        self.result = result
    }
    
    func fetchBookingList(year: Int, month: Int) async throws -> [BookingResponse] {
        switch result {
        case .success(let response):
            return response
        case .failure(let failure):
            throw failure
        }
    }
}
