//
//  StoreTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 17/04/26.
//

import Combine
import CoreLocation
@testable import MVL
import LocationMock
import XCTest

@MainActor
final class StoreTests: XCTestCase {
    func testInitRequestsWhenInUseAuthorizationWhenNotAuthorized() {
        let (_, locationService, _, _, _, _) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .denied
        )

        XCTAssertTrue(locationService.didRequestWhenInUseAuthorization)
        XCTAssertFalse(locationService.didStartUpdatingLocation)
    }

    func testInitStartsUpdatingLocationWhenAuthorized() {
        let (_, locationService, _, _, _, _) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .authorizedWhenInUse
        )

        XCTAssertTrue(locationService.didStartUpdatingLocation)
        XCTAssertFalse(locationService.didRequestWhenInUseAuthorization)
    }

    func testLocationServiceUpdateFetchesAndPublishesCurrentLocation() async {
        let (store, locationService, aqiUseCase, reverseUseCase, _, _) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .authorizedWhenInUse,
            reverseGeocodeResult: .success(.init(latitude: 13.0827, longitude: 80.2707, city: "Chennai"))
        )
        let currentLocationPublished = expectation(description: "Current location published")
        var cancellables = Set<AnyCancellable>()

        store.$currentLocation
            .dropFirst()
            .compactMap { $0 }
            .sink { location in
                guard location.latitude == 13.0827, location.longitude == 80.2707 else { return }
                currentLocationPublished.fulfill()
            }
            .store(in: &cancellables)

        locationService.locationSubject.send(CLLocation(latitude: 13.0827, longitude: 80.2707))
        await fulfillment(of: [currentLocationPublished], timeout: 1)

        XCTAssertEqual(reverseUseCase.invokedRequests.last, ReverseGeocoderRequest(latitude: 13.0827, longitude: 80.2707))
        XCTAssertEqual(aqiUseCase.invokedRequests.last, AqiDataRequest(latitude: 13.0827, longitude: 80.2707))
        XCTAssertEqual(store.currentLocation?.name, "Chennai")
        XCTAssertEqual(store.currentLocation?.aqi, 162)
        XCTAssertEqual(store.fetchStatus, .success)
    }

    func testFetchAqiDataAndCurrentLocationPublishesFailureWhenReverseGeocodingFails() async {
        let error = MVLError(localizedDescription: "Sample error")
        let (store, _, _, _, _, _) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .denied,
            reverseGeocodeResult: .failure(error)
        )

        await store.fetchAqiDataAndCurrentLocation(.sample)

        XCTAssertNil(store.currentLocation)
        if case let .failure(message) = store.fetchStatus {
            XCTAssertEqual(message, error.localizedDescription)
        } else {
            XCTFail("Expected failure status")
        }
    }

    func testBookStoresBookingOnSuccess() async {
        let (store, _, _, _, bookingUseCase, _) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .denied,
            bookingResult: .success(.sample)
        )
        let locationA = Location.mock(name: "Bangalore", aqi: 162, nickname: "Home")
        let locationB = Location.mock(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Mangalore",
            latitude: 12.9635,
            longitude: 77.5789,
            aqi: 200,
            nickname: "Work"
        )

        await store.book(locationA: locationA, locationB: locationB)

        XCTAssertEqual(bookingUseCase.invokedRequests.count, 1)
        XCTAssertEqual(bookingUseCase.invokedRequests.first?.locationA, locationA)
        XCTAssertEqual(bookingUseCase.invokedRequests.first?.locationB, locationB)
        XCTAssertEqual(store.booking?.id, Booking.sample.id)
        XCTAssertEqual(store.fetchStatus, .success)
    }

    func testBookPublishesFailureWhenBookingFails() async {
        let error = MVLError(localizedDescription: "Sample error")
        let (store, _, _, _, bookingUseCase, _) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .denied,
            bookingResult: .failure(error)
        )

        await store.book(locationA: .mock(), locationB: .mock(name: "Office"))

        XCTAssertEqual(bookingUseCase.invokedRequests.count, 1)
        XCTAssertNil(store.booking)
        if case let .failure(message) = store.fetchStatus {
            XCTAssertEqual(message, error.localizedDescription)
        } else {
            XCTFail("Expected failure status")
        }
    }

    func testFetchBookingsStoresBookingsOnSuccess() async {
        let anotherBooking = Booking(
            response: BookingResponse(
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
        )
        let bookings = [Booking.sample, anotherBooking]
        let (store, _, _, _, _, bookingListUseCase) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .denied,
            bookingListResult: .success(bookings)
        )

        await store.fetchBookings(year: 2026, month: 4)

        XCTAssertEqual(bookingListUseCase.invokedRequests.first?.year, 2026)
        XCTAssertEqual(bookingListUseCase.invokedRequests.first?.month, 4)
        XCTAssertEqual(store.bookings?.map(\.id), bookings.map(\.id))
        XCTAssertEqual(store.fetchStatus, .success)
    }

    func testFetchBookingsPublishesFailureWhenUseCaseFails() async {
        let error = MVLError(localizedDescription: "Sample error")
        let (store, _, _, _, _, bookingListUseCase) = buildStore(
            locationServiceLocation: nil,
            authorizationStatus: .denied,
            bookingListResult: .failure(error)
        )

        await store.fetchBookings(year: 2026, month: 4)

        XCTAssertEqual(bookingListUseCase.invokedRequests.count, 1)
        XCTAssertNil(store.bookings)
        if case let .failure(message) = store.fetchStatus {
            XCTAssertEqual(message, error.localizedDescription)
        } else {
            XCTFail("Expected failure status")
        }
    }

    private func buildStore(
        locationServiceLocation: CLLocation? = nil,
        authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse,
        aqiDataResult: Result<AqiData, MVLError> = .success(.sample),
        reverseGeocodeResult: Result<ReverseGeocode, MVLError> = .success(.sample),
        bookingResult: Result<Booking, MVLError> = .success(.sample),
        bookingListResult: Result<[Booking], MVLError> = .success([.sample])
    ) -> (
        store: Store,
        locationService: MockLocationService,
        aqiUseCase: MockAqiDataUseCase,
        reverseUseCase: MockReverseGeocoderUseCase,
        bookingUseCase: MockBookingUseCase,
        bookingListUseCase: MockBookingListUseCase
    ) {
        let locationService = MockLocationService(
            location: locationServiceLocation,
            authorizationStatus: authorizationStatus
        )
        let aqiUseCase = MockAqiDataUseCase(result: aqiDataResult)
        let reverseUseCase = MockReverseGeocoderUseCase(result: reverseGeocodeResult)
        let bookingUseCase = MockBookingUseCase(result: bookingResult)
        let bookingListUseCase = MockBookingListUseCase(result: bookingListResult)
        let store = Store(
            locationService: locationService,
            aqiDataUseCase: aqiUseCase,
            reverseGeocodingUseCase: reverseUseCase,
            bookingUseCase: bookingUseCase,
            bookingListUseCase: bookingListUseCase
        )

        return (
            store,
            locationService,
            aqiUseCase,
            reverseUseCase,
            bookingUseCase,
            bookingListUseCase
        )
    }
}
