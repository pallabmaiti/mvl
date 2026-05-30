//
//  MockAqiDataUseCase.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL

struct AqiDataRequest: Equatable {
    let latitude: Double
    let longitude: Double
}

final class MockAqiDataUseCase: AqiDataUseCase {
    var result: Result<AqiData, MVLError>
    private(set) var invokedRequests: [AqiDataRequest] = []

    init(result: Result<AqiData, MVLError>) {
        self.result = result
    }

    func invoke(latitude: Double, longitude: Double) async throws(MVLError) -> AqiData {
        invokedRequests.append(AqiDataRequest(latitude: latitude, longitude: longitude))
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
