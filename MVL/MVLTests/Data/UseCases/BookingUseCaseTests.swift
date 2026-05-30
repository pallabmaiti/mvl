//
//  BookingUseCaseTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL
import XCTest

@MainActor
final class BookingUseCaseTests: XCTestCase {
    func testInvokeMapsRepositoryResponseToDomainModel() async throws {
        let useCase = BookingUseCaseImpl(
            repository: MockBookingRepositoryImpl(result: .success(.sampleData))
        )

        let result = try await useCase.invoke(
            locationA: .mock(name: "Bangalore", latitude: 12.9629, longitude: 77.5775, aqi: 162),
            locationB: .mock(name: "Mangalore", latitude: 12.9635, longitude: 77.5789, aqi: 200)
        )

        XCTAssertEqual(result.id, BookingResponse.sampleData.id)
        XCTAssertEqual(result.a.id, BookingResponse.sampleData.a.id)
        XCTAssertEqual(result.a.latitude, 12.9629)
        XCTAssertEqual(result.a.longitude, 77.5775)
        XCTAssertEqual(result.a.aqi, 162)
        XCTAssertEqual(result.a.name, "Bangalore")
        XCTAssertEqual(result.b.id, BookingResponse.sampleData.b.id)
        XCTAssertEqual(result.b.latitude, 12.9635)
        XCTAssertEqual(result.b.longitude, 77.5789)
        XCTAssertEqual(result.b.aqi, 200)
        XCTAssertEqual(result.b.name, "Mangalore")
        XCTAssertEqual(result.price, 5000)
    }

    func testInvokePropagatesRepositoryError() async {
        let useCase = BookingUseCaseImpl(
            repository: MockBookingRepositoryImpl(result: .failure(TestError.sample))
        )

        do {
            _ = try await useCase.invoke(locationA: .mock(), locationB: .mock(name: "Office"))
            XCTFail("Expected repository error")
        } catch {
            XCTAssertEqual(error.localizedDescription, TestError.sample.localizedDescription)
        }
    }
}
