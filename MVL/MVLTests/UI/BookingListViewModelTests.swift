//
//  BookingListViewModelTests.swift
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
final class BookingListViewModelTests: XCTestCase {
    func testBookingListViewModelStartsWithEmptyDerivedState() {
        let (viewModel, _, _) = buildBookingListViewModel()

        XCTAssertNil(viewModel.bookings)
        XCTAssertEqual(viewModel.fetchStatus, .idle)
        XCTAssertEqual(viewModel.totalBookings, 0)
        XCTAssertEqual(viewModel.totalPrice, 0)
    }

    func testFetchBookingsRequestsCurrentMonthAndYear() async {
        let (viewModel, _, bookingListUseCase) = buildBookingListViewModel()
        let currentDate = Calendar.current.dateComponents([.year, .month], from: Date())
        let bookingsRequested = expectation(description: "Booking list use case invoked")
        bookingListUseCase.onInvoke = { _ in
            bookingsRequested.fulfill()
        }

        viewModel.fetchBookings()
        await fulfillment(of: [bookingsRequested], timeout: 1)

        XCTAssertEqual(bookingListUseCase.invokedRequests.first?.year, currentDate.year)
        XCTAssertEqual(bookingListUseCase.invokedRequests.first?.month, currentDate.month)
    }

    func testFetchBookingsPublishesBookingsAndDerivedTotalsOnSuccess() async {
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
        let (viewModel, _, _) = buildBookingListViewModel(bookingListResult: .success(bookings))
        let bookingsPublished = expectation(description: "Bookings published")
        var cancellables = Set<AnyCancellable>()

        viewModel.$bookings
            .dropFirst()
            .sink { publishedBookings in
                guard publishedBookings?.count == bookings.count else { return }
                bookingsPublished.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchBookings()
        await fulfillment(of: [bookingsPublished], timeout: 1)

        XCTAssertEqual(viewModel.fetchStatus, .success)
        XCTAssertEqual(viewModel.bookings?.map(\.id), bookings.map(\.id))
        XCTAssertEqual(viewModel.totalBookings, 2)
        XCTAssertEqual(viewModel.totalPrice, 8200)
    }

    func testFetchBookingsPublishesFailureStatusWhenUseCaseFails() async {
        let error = MVLError(localizedDescription: "Sample error")
        let (viewModel, _, _) = buildBookingListViewModel(bookingListResult: .failure(error))
        let failurePublished = expectation(description: "Failure status published")
        var cancellables = Set<AnyCancellable>()

        viewModel.$fetchStatus
            .dropFirst()
            .sink { status in
                if case .failure = status {
                    failurePublished.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchBookings()
        await fulfillment(of: [failurePublished], timeout: 1)

        XCTAssertNil(viewModel.bookings)
        if case let .failure(message) = viewModel.fetchStatus {
            XCTAssertEqual(message, error.localizedDescription)
        } else {
            XCTFail("Expected failure status")
        }
    }

    private func buildBookingListViewModel(
        bookingListResult: Result<[Booking], MVLError> = .success([.sample])
    ) -> (viewModel: BookingListView.ViewModel, store: Store, bookingListUseCase: MockBookingListUseCase) {
        let locationService = MockLocationService(location: nil, authorizationStatus: .denied)
        let aqiUseCase = MockAqiDataUseCase(result: .success(.sample))
        let reverseUseCase = MockReverseGeocoderUseCase(result: .success(.sample))
        let bookingUseCase = MockBookingUseCase(result: .success(.sample))
        let bookingListUseCase = MockBookingListUseCase(result: bookingListResult)
        let store = Store(
            locationService: locationService,
            aqiDataUseCase: aqiUseCase,
            reverseGeocodingUseCase: reverseUseCase,
            bookingUseCase: bookingUseCase,
            bookingListUseCase: bookingListUseCase
        )

        return (BookingListView.ViewModel(store: store), store, bookingListUseCase)
    }
}
