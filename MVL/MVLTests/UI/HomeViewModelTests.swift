//
//  HomeViewModelTests.swift
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
final class HomeViewModelTests: XCTestCase {
    func testHomeViewModelStartsWithExpectedDefaults() {
        let (viewModel, _, _, _, _) = buildHomeViewModel(locationServiceLocation: nil)

        XCTAssertNil(viewModel.currentLocation)
        XCTAssertNil(viewModel.locationA)
        XCTAssertNil(viewModel.locationB)
        XCTAssertNil(viewModel.selectedLocation)
        XCTAssertFalse(viewModel.isBookingPresented)
        XCTAssertEqual(viewModel.primaryButtonTitle, "Set A")
        XCTAssertEqual(viewModel.locationAName, "A")
        XCTAssertEqual(viewModel.locationBName, "B")
        XCTAssertEqual(viewModel.fetchStatus, .idle)
        XCTAssertEqual(viewModel.pinIcon, "icon-pin")
        XCTAssertNil(viewModel.bookingViewModel)
    }

    func testUpdateMapCenterPublishesCurrentLocationAndSuccessStatus() async {
        let (viewModel, _, _, _, _) = buildHomeViewModel(locationServiceLocation: nil)
        let coordinate = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
        let locationPublished = expectation(description: "Current location published")
        let fetchSucceeded = expectation(description: "Fetch status published")
        var cancellables = Set<AnyCancellable>()

        viewModel.$currentLocation
            .dropFirst()
            .compactMap { $0 }
            .sink { publishedLocation in
                guard publishedLocation.latitude == coordinate.latitude,
                      publishedLocation.longitude == coordinate.longitude else {
                    return
                }
                locationPublished.fulfill()
            }
            .store(in: &cancellables)

        viewModel.$fetchStatus
            .dropFirst()
            .sink { status in
                if case .success = status {
                    fetchSucceeded.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.updateMapCenter(coordinate)
        await fulfillment(of: [locationPublished, fetchSucceeded], timeout: 1)

        XCTAssertEqual(viewModel.currentLocation?.name, "Electronic City, Bangalore")
        XCTAssertEqual(viewModel.currentLocation?.aqi, 162)
        XCTAssertEqual(viewModel.currentLocation?.latitude, coordinate.latitude)
        XCTAssertEqual(viewModel.currentLocation?.longitude, coordinate.longitude)
        XCTAssertEqual(viewModel.fetchStatus, .success)
    }

    func testUpdateMapCenterPublishesFailureStatusWhenFetchFails() async {
        let error = MVLError(localizedDescription: "Sample error")
        let (viewModel, _, _, _, _) = buildHomeViewModel(
            locationServiceLocation: nil,
            reverseGeocodeResult: .failure(error)
        )
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

        viewModel.updateMapCenter(CLLocationCoordinate2D(latitude: 12.9629, longitude: 77.5775))
        await fulfillment(of: [failurePublished], timeout: 1)

        XCTAssertNil(viewModel.currentLocation)
        if case let .failure(message) = viewModel.fetchStatus {
            XCTAssertEqual(message, error.localizedDescription)
        } else {
            XCTFail("Expected failure status")
        }
    }

    func testPrimaryButtonBuildsBookingFlowFromCurrentLocation() async {
        let (viewModel, _, _, _, _) = buildHomeViewModel(locationServiceLocation: nil)
        var cancellables = Set<AnyCancellable>()

        let firstLocationPublished = expectation(description: "First current location published")
        viewModel.$currentLocation
            .dropFirst()
            .compactMap { $0 }
            .sink { publishedLocation in
                guard publishedLocation.latitude == 12.9629,
                      publishedLocation.longitude == 77.5775 else {
                    return
                }
                firstLocationPublished.fulfill()
            }
            .store(in: &cancellables)

        viewModel.updateMapCenter(CLLocationCoordinate2D(latitude: 12.9629, longitude: 77.5775))
        await fulfillment(of: [firstLocationPublished], timeout: 1)

        viewModel.onPrimaryButton()

        XCTAssertEqual(viewModel.locationA?.latitude, 12.9629)
        XCTAssertEqual(viewModel.locationA?.longitude, 77.5775)
        XCTAssertEqual(viewModel.primaryButtonTitle, "Set B")
        XCTAssertNil(viewModel.bookingViewModel)

        let secondLocationPublished = expectation(description: "Second current location published")
        viewModel.$currentLocation
            .dropFirst()
            .compactMap { $0 }
            .sink { publishedLocation in
                guard publishedLocation.latitude == 28.6139,
                      publishedLocation.longitude == 77.2090 else {
                    return
                }
                secondLocationPublished.fulfill()
            }
            .store(in: &cancellables)

        viewModel.updateMapCenter(CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090))
        await fulfillment(of: [secondLocationPublished], timeout: 1)

        viewModel.onPrimaryButton()

        XCTAssertEqual(viewModel.locationB?.latitude, 28.6139)
        XCTAssertEqual(viewModel.locationB?.longitude, 77.2090)
        XCTAssertEqual(viewModel.primaryButtonTitle, "Book")
        XCTAssertNotNil(viewModel.bookingViewModel)
        XCTAssertFalse(viewModel.isBookingPresented)

        viewModel.onPrimaryButton()

        XCTAssertTrue(viewModel.isBookingPresented)
    }

    func testLocationSelectionAndNicknameUpdatesSavedSlots() async {
        let (viewModel, _, _, _, _) = buildHomeViewModel(locationServiceLocation: nil)
        var cancellables = Set<AnyCancellable>()

        let firstLocationPublished = expectation(description: "First current location published")
        viewModel.$currentLocation
            .dropFirst()
            .compactMap { $0 }
            .sink { publishedLocation in
                guard publishedLocation.latitude == 12.9629,
                      publishedLocation.longitude == 77.5775 else {
                    return
                }
                firstLocationPublished.fulfill()
            }
            .store(in: &cancellables)

        viewModel.updateMapCenter(CLLocationCoordinate2D(latitude: 12.9629, longitude: 77.5775))
        await fulfillment(of: [firstLocationPublished], timeout: 1)
        viewModel.onPrimaryButton()

        let secondLocationPublished = expectation(description: "Second current location published")
        viewModel.$currentLocation
            .dropFirst()
            .compactMap { $0 }
            .sink { publishedLocation in
                guard publishedLocation.latitude == 19.0760,
                      publishedLocation.longitude == 72.8777 else {
                    return
                }
                secondLocationPublished.fulfill()
            }
            .store(in: &cancellables)

        viewModel.updateMapCenter(CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777))
        await fulfillment(of: [secondLocationPublished], timeout: 1)
        viewModel.onPrimaryButton()

        viewModel.onLocationA()

        XCTAssertEqual(viewModel.selectedLocation?.slot, .locationA)
        XCTAssertEqual(viewModel.selectedLocation?.location.id, viewModel.locationA?.id)

        if let selectedLocation = viewModel.selectedLocation {
            viewModel.update(nickname: "Home", of: selectedLocation)
            viewModel.update(nickname: "", of: selectedLocation)
        } else {
            XCTFail("Expected selected location A")
        }

        XCTAssertEqual(viewModel.locationA?.nickname, "Home")
        XCTAssertEqual(viewModel.locationAName, "Home")

        viewModel.onLocationB()

        XCTAssertEqual(viewModel.selectedLocation?.slot, .locationB)
        XCTAssertEqual(viewModel.selectedLocation?.location.id, viewModel.locationB?.id)

        if let selectedLocation = viewModel.selectedLocation {
            viewModel.update(nickname: "Work", of: selectedLocation)
        } else {
            XCTFail("Expected selected location B")
        }

        XCTAssertEqual(viewModel.locationB?.nickname, "Work")
        XCTAssertEqual(viewModel.locationBName, "Work")
    }

    private func buildHomeViewModel(
        locationServiceLocation: CLLocation? = nil,
        authorizationStatus: CLAuthorizationStatus = .denied,
        aqiDataResult: Result<AqiData, MVLError> = .success(.sample),
        reverseGeocodeResult: Result<ReverseGeocode, MVLError> = .success(.sample),
        bookingResult: Result<Booking, MVLError> = .success(.sample),
        bookingListResult: Result<[Booking], MVLError> = .success([.sample])
    ) -> (
        viewModel: HomeView.ViewModel,
        store: Store,
        locationService: MockLocationService,
        aqiUseCase: MockAqiDataUseCase,
        reverseUseCase: MockReverseGeocoderUseCase
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
            HomeView.ViewModel(store: store),
            store,
            locationService,
            aqiUseCase,
            reverseUseCase
        )
    }
}
