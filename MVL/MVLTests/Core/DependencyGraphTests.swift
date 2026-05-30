//
//  DependencyGraphTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 17/04/26.
//

@testable import MVL
import Location
import Networking
import XCTest

@MainActor
final class DependencyGraphTests: XCTestCase {
    func testRepositoriesProviderCreatesExpectedRepositoryImplementations() {
        let provider = RepositoriesProviderImpl(externalDependencies: makeDependencies())

        XCTAssertTrue(provider.aqiDataRepository is AqiDataRepositoryImpl)
        XCTAssertTrue(provider.reverseGeocoderRepository is ReverseGeocoderRepositoryImpl)
        XCTAssertTrue(provider.bookingRepository is BookingRepositoryImpl)
        XCTAssertTrue(provider.bookingListRepository is BookingListRepositoryImpl)
    }

    func testUseCasesProviderBuildsUseCasesFromInjectedRepositories() async throws {
        let bookingResponse = BookingResponse(
            id: UUID(uuidString: "66666666-6666-6666-6666-666666666666")!,
            a: .init(
                id: UUID(uuidString: "77777777-7777-7777-7777-777777777777")!,
                latitude: 13.0827,
                longitude: 80.2707,
                aqi: 111,
                name: "Chennai"
            ),
            b: .init(
                id: UUID(uuidString: "88888888-8888-8888-8888-888888888888")!,
                latitude: 17.3850,
                longitude: 78.4867,
                aqi: 92,
                name: "Hyderabad"
            ),
            price: 4200
        )
        let repositories = StubRepositoriesProvider(
            aqiDataRepository: MockAqiDataRepositoryImpl(
                result: .success(
                    AqiDataResponse(
                        status: "ok",
                        data: .init(aqi: 201, id: 9, city: .init(name: "Chennai"))
                    )
                )
            ),
            reverseGeocoderRepository: MockReverseGeocoderRepositoryImpl(
                response: .success(
                    ReverseGeocodeResponse(
                        latitude: 13.0827,
                        longitude: 80.2707,
                        localityInfo: .init(
                            administrative: [
                                .init(order: 6, name: "Tamil Nadu"),
                                .init(order: 4, name: "Chennai"),
                            ]
                        )
                    )
                )
            ),
            bookingRepository: MockBookingRepositoryImpl(result: .success(bookingResponse)),
            bookingListRepository: MockBookingListRepositoryImpl(result: .success([bookingResponse]))
        )
        let provider = UseCasesProviderImpl(repositories: repositories)

        let aqiData = try await provider.aqiDataUseCase.invoke(latitude: 13.0827, longitude: 80.2707)
        let reverseGeocode = try await provider.reverseGeocoderUseCase.invoke(
            latitude: 13.0827,
            longitude: 80.2707
        )
        let booking = try await provider.bookingUseCase.invoke(
            locationA: .mock(name: "Chennai", latitude: 13.0827, longitude: 80.2707, aqi: 111),
            locationB: .mock(name: "Hyderabad", latitude: 17.3850, longitude: 78.4867, aqi: 92)
        )
        let bookings = try await provider.bookingListUseCase.invoke(year: 2026, month: 4)

        XCTAssertEqual(aqiData.city, "Chennai")
        XCTAssertEqual(aqiData.aqi, 201)
        XCTAssertEqual(reverseGeocode.city, "Chennai, Tamil Nadu")
        XCTAssertEqual(booking.id, bookingResponse.id)
        XCTAssertEqual(booking.price, 4200)
        XCTAssertEqual(bookings.count, 1)
        XCTAssertEqual(bookings.first?.id, bookingResponse.id)
    }

    func testDependencyGraphCreatesExpectedProvidersAndUseCases() {
        let graph = DependencyGraphImpl(dependencies: makeDependencies())

        XCTAssertTrue(graph.repositories is RepositoriesProviderImpl)
        XCTAssertTrue(graph.useCases is UseCasesProviderImpl)
        XCTAssertTrue(graph.useCases.aqiDataUseCase is AqiDataUseCaseImpl)
        XCTAssertTrue(graph.useCases.reverseGeocoderUseCase is ReverseGeocoderUseCaseImpl)
        XCTAssertTrue(graph.useCases.bookingUseCase is BookingUseCaseImpl)
        XCTAssertTrue(graph.useCases.bookingListUseCase is BookingListUseCaseImpl)
    }

    private func makeDependencies() -> ExternalDependencies {
        ExternalDependencies(
            networking: Networking(),
            locationService: LocationServiceImpl()
        )
    }
}

private struct StubRepositoriesProvider: RepositoriesProvider {
    let aqiDataRepository: AqiDataRepository
    let reverseGeocoderRepository: ReverseGeocoderRepository
    let bookingRepository: BookingRepository
    let bookingListRepository: BookingListRepository
}
