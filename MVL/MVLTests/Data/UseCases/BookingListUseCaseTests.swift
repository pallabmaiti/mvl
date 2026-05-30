//
//  BookingListUseCaseTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MVL
import XCTest

@MainActor
final class BookingListUseCaseTests: XCTestCase {
    func testInvokeMapsRepositoryResponseToDomainModels() async throws {
        let sampleResponse = BookingResponse.sampleData
        let anotherResponse = BookingResponse(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333")!,
            a: .init(
                id: UUID(uuidString: "44444444-4444-4444-4444-444444444444")!,
                latitude: 28.6139,
                longitude: 77.2090,
                aqi: 145,
                name: "Delhi"
            ),
            b: .init(
                id: UUID(uuidString: "55555555-5555-5555-5555-555555555555")!,
                latitude: 19.0760,
                longitude: 72.8777,
                aqi: 98,
                name: "Mumbai"
            ),
            price: 3200
        )
        let useCase = BookingListUseCaseImpl(
            repository: MockBookingListRepositoryImpl(result: .success([sampleResponse, anotherResponse]))
        )

        let result = try await useCase.invoke(year: 2026, month: 4)

        XCTAssertEqual(result.count, 2)

        XCTAssertEqual(result[0].id, sampleResponse.id)
        XCTAssertEqual(result[0].a.id, sampleResponse.a.id)
        XCTAssertEqual(result[0].a.latitude, sampleResponse.a.latitude)
        XCTAssertEqual(result[0].a.longitude, sampleResponse.a.longitude)
        XCTAssertEqual(result[0].a.aqi, sampleResponse.a.aqi)
        XCTAssertEqual(result[0].a.name, sampleResponse.a.name)
        XCTAssertEqual(result[0].b.id, sampleResponse.b.id)
        XCTAssertEqual(result[0].b.latitude, sampleResponse.b.latitude)
        XCTAssertEqual(result[0].b.longitude, sampleResponse.b.longitude)
        XCTAssertEqual(result[0].b.aqi, sampleResponse.b.aqi)
        XCTAssertEqual(result[0].b.name, sampleResponse.b.name)
        XCTAssertEqual(result[0].price, sampleResponse.price)

        XCTAssertEqual(result[1].id, anotherResponse.id)
        XCTAssertEqual(result[1].a.id, anotherResponse.a.id)
        XCTAssertEqual(result[1].a.latitude, anotherResponse.a.latitude)
        XCTAssertEqual(result[1].a.longitude, anotherResponse.a.longitude)
        XCTAssertEqual(result[1].a.aqi, anotherResponse.a.aqi)
        XCTAssertEqual(result[1].a.name, anotherResponse.a.name)
        XCTAssertEqual(result[1].b.id, anotherResponse.b.id)
        XCTAssertEqual(result[1].b.latitude, anotherResponse.b.latitude)
        XCTAssertEqual(result[1].b.longitude, anotherResponse.b.longitude)
        XCTAssertEqual(result[1].b.aqi, anotherResponse.b.aqi)
        XCTAssertEqual(result[1].b.name, anotherResponse.b.name)
        XCTAssertEqual(result[1].price, anotherResponse.price)
    }

    func testInvokePropagatesRepositoryError() async {
        let useCase = BookingListUseCaseImpl(
            repository: MockBookingListRepositoryImpl(result: .failure(TestError.sample))
        )

        do {
            _ = try await useCase.invoke(year: 2026, month: 4)
            XCTFail("Expected repository error")
        } catch {
            XCTAssertEqual(error.localizedDescription, TestError.sample.localizedDescription)
        }
    }
}
