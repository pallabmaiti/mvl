//
//  MockBookingUseCase.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL

struct BookingRequest {
    let locationA: Location
    let locationB: Location
    
    static let sample = BookingRequest(locationA: .sampleData, locationB: .sampleData)
}

final class MockBookingUseCase: BookingUseCase {
    var result: Result<Booking, MVLError>
    var onInvoke: ((BookingRequest) -> Void)?
    private(set) var invokedRequests: [BookingRequest] = []
    
    init(result: Result<Booking, MVLError>) {
        self.result = result
    }
    
    func invoke(locationA: Location, locationB: Location) async throws(MVLError) -> Booking {
        let request = BookingRequest(locationA: locationA, locationB: locationB)
        invokedRequests.append(request)
        onInvoke?(request)
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
