//
//  AqiDataUseCaseTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL
import XCTest

@MainActor
final class AqiDataUseCaseTests: XCTestCase {
    func testInvokeMapsRepositoryResponseToDomainModel() async throws {
        let useCase = AqiDataUseCaseImpl(repository: MockAqiDataRepositoryImpl(result: .success(.sampleData)))

        let result = try await useCase.invoke(latitude: 12.9629, longitude: 77.5775)

        XCTAssertEqual(result.aqi, 162)
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.city, "Bangalore")
    }

    func testInvokePropagatesRepositoryError() async {
        let useCase = AqiDataUseCaseImpl(
            repository: MockAqiDataRepositoryImpl(result: .failure(TestError.sample))
        )

        do {
            _ = try await useCase.invoke(latitude: 12.9629, longitude: 77.5775)
            XCTFail("Expected repository error")
        } catch {
            XCTAssertEqual(error.localizedDescription, TestError.sample.localizedDescription)
        }
    }
}
