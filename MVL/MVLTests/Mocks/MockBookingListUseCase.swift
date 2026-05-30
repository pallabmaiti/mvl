//
//  MockBookingListUseCase.swift
//  MVLTests
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL

struct BookingListRequest {
    let year: Int
    let month: Int
    
    static let sample = BookingListRequest(year: 2026, month: 4)
}

final class MockBookingListUseCase: BookingListUseCase {
    var result: Result<[Booking], MVLError>
    var onInvoke: ((BookingListRequest) -> Void)?
    private(set) var invokedRequests: [BookingListRequest] = []
    
    init(result: Result<[Booking], MVLError>) {
        self.result = result
    }
    
    func invoke(year: Int, month: Int) async throws(MVLError) -> [Booking] {
        let request = BookingListRequest(year: year, month: month)
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
