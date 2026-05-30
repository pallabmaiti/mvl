//
//  MockReverseGeocoderUseCase.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL

struct ReverseGeocoderRequest: Equatable {
    let latitude: Double
    let longitude: Double

    static let sample = ReverseGeocoderRequest(latitude: 12.9629, longitude: 77.5775)
}

final class MockReverseGeocoderUseCase: ReverseGeocoderUseCase {
    var result: Result<ReverseGeocode, MVLError>
    private(set) var invokedRequests: [ReverseGeocoderRequest] = []

    init(result: Result<ReverseGeocode, MVLError>) {
        self.result = result
    }

    func invoke(latitude: Double, longitude: Double) async throws(MVLError) -> ReverseGeocode {
        invokedRequests.append(ReverseGeocoderRequest(latitude: latitude, longitude: longitude))
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
