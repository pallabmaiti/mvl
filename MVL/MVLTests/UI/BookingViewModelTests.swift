//
//  BookingViewModelTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 16/04/26.
//

import Combine
import CoreLocation
@testable import MVL
import LocationMock
import XCTest

@MainActor
final class BookingViewModelTests: XCTestCase {
    func testBookingViewModelExposesLocationDetails() {
        let locationA = Location.mock(name: "Bangalore", aqi: 162, nickname: "Home")
        let locationB = Location.mock(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Mangalore",
            latitude: 12.9635,
            longitude: 77.5789,
            aqi: 200,
            nickname: "Work"
        )
        let viewModel = buildBookingViewModel(locationA: locationA, locationB: locationB).viewModel

        XCTAssertEqual(viewModel.locationAName, "Bangalore")
        XCTAssertEqual(viewModel.locationANickname, "Home")
        XCTAssertEqual(viewModel.locationAAqi, "162")
        XCTAssertEqual(viewModel.locationBName, "Mangalore")
        XCTAssertEqual(viewModel.locationBNickname, "Work")
        XCTAssertEqual(viewModel.locationBAqi, "200")
    }

    func testBookRequestsBookingForProvidedLocations() async {
        let locationA = Location.mock(name: "Bangalore", aqi: 162, nickname: "Home")
        let locationB = Location.mock(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Mangalore",
            latitude: 12.9635,
            longitude: 77.5789,
            aqi: 200,
            nickname: "Work"
        )
        let (viewModel, _, bookingUseCase) = buildBookingViewModel(locationA: locationA, locationB: locationB)
        let bookingRequested = expectation(description: "Booking use case invoked")
        bookingUseCase.onInvoke = { _ in
            bookingRequested.fulfill()
        }

        viewModel.book()
        await fulfillment(of: [bookingRequested], timeout: 1)

        XCTAssertEqual(bookingUseCase.invokedRequests.first?.locationA, locationA)
        XCTAssertEqual(bookingUseCase.invokedRequests.first?.locationB, locationB)
    }

    func testBookPublishesBookingOnSuccessfulResponse() async {
        let (viewModel, _, _) = buildBookingViewModel(bookingResult: .success(.sample))
        let bookingPublished = expectation(description: "Booking published")
        var cancellables = Set<AnyCancellable>()

        viewModel.$booking
            .dropFirst()
            .compactMap { $0 }
            .sink { _ in
                bookingPublished.fulfill()
            }
            .store(in: &cancellables)

        viewModel.book()
        await fulfillment(of: [bookingPublished], timeout: 1)

        XCTAssertEqual(viewModel.booking?.id, Booking.sample.id)
        XCTAssertEqual(viewModel.booking?.price, Booking.sample.price)
        XCTAssertEqual(viewModel.booking?.a.name, Booking.sample.a.name)
        XCTAssertEqual(viewModel.booking?.b.name, Booking.sample.b.name)
    }

    func testBookKeepsBookingNilWhenStoreBookingFails() async {
        let (viewModel, _, bookingUseCase) = buildBookingViewModel(
            bookingResult: .failure(MVLError(localizedDescription: "Sample error"))
        )
        let bookingRequested = expectation(description: "Booking use case invoked")
        bookingUseCase.onInvoke = { _ in
            bookingRequested.fulfill()
        }

        viewModel.book()
        await fulfillment(of: [bookingRequested], timeout: 1)

        XCTAssertNil(viewModel.booking)
    }

    private func buildBookingViewModel(
        locationA: Location = .mock(name: "Bangalore", aqi: 162, nickname: "Home"),
        locationB: Location = .mock(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "Mangalore",
            latitude: 12.9635,
            longitude: 77.5789,
            aqi: 200,
            nickname: "Work"
        ),
        bookingResult: Result<Booking, MVLError> = .success(.sample)
    ) -> (viewModel: BookingView.ViewModel, store: Store, bookingUseCase: MockBookingUseCase) {
        let (store, _, _, _, bookingUseCase, _) = buildStoreDependencies(
            bookingResult: bookingResult
        )
        
        return (
            BookingView.ViewModel(locationA: locationA, locationB: locationB, store: store),
            store,
            bookingUseCase
        )
    }
}
