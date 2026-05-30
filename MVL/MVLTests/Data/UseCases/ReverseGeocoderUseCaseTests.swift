//
//  ReverseGeocoderUseCaseTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL
import XCTest

@MainActor
final class ReverseGeocoderUseCaseTests: XCTestCase {
    func testInvokeMapsRepositoryResponseToDomainModel() async throws {
        let useCase = ReverseGeocoderUseCaseImpl(
            repository: MockReverseGeocoderRepositoryImpl(response: .success(.sampleData))
        )

        let result = try await useCase.invoke(latitude: 12.9629, longitude: 77.5775)

        XCTAssertEqual(result.city, "Electronic City, Bangalore")
    }

    func testInvokeUsesOnlyFirstTwoAdministrativeElementsWhenAvailable() async throws {
        let response = ReverseGeocodeResponse(
            latitude: 12.9629,
            longitude: 77.5775,
            localityInfo: .init(
                administrative: [
                    .init(order: 6, name: "Karnataka"),
                    .init(order: 4, name: "Electronic City"),
                    .init(order: 5, name: "Bangalore")
                ]
            )
        )
        let useCase = ReverseGeocoderUseCaseImpl(
            repository: MockReverseGeocoderRepositoryImpl(response: .success(response))
        )

        let result = try await useCase.invoke(latitude: 12.9629, longitude: 77.5775)

        XCTAssertEqual(result.city, "Electronic City, Bangalore")
    }

    func testInvokePropagatesRepositoryError() async {
        let useCase = ReverseGeocoderUseCaseImpl(
            repository: MockReverseGeocoderRepositoryImpl(response: .failure(TestError.sample))
        )

        do {
            _ = try await useCase.invoke(latitude: 12.9629, longitude: 77.5775)
            XCTFail("Expected repository error")
        } catch {
            XCTAssertEqual(error.localizedDescription, TestError.sample.localizedDescription)
        }
    }
}
