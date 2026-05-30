//
//  TestUtils.swift
//  MVLTests
//
//  Created by Pallab Maiti on 16/04/26.
//

import CoreLocation
@testable import MVL
import LocationMock
import XCTest

enum TestError: Error, Equatable {
    case sample
}

@MainActor
func buildStoreDependencies(
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
    let locationService = MockLocationService(authorizationStatus: authorizationStatus)
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

extension CLLocation {
    static let sample = CLLocation(latitude: 12.9629, longitude: 77.5775)
}

extension AqiData {
    static let sample = AqiData(aqi: 162, id: 1, city: "Bangalore")
}

extension ReverseGeocode {
    static let sample = ReverseGeocode(latitude: 12.9629, longitude: 77.5775, city: "Electronic City, Bangalore")
}

extension Location {
    static func mock(
        id: UUID = UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
        name: String = "Bangalore",
        latitude: Double = 12.9629,
        longitude: Double = 77.5775,
        aqi: Int = 162,
        nickname: String? = nil
    ) -> Location {
        Location(
            id: id,
            name: name,
            latitude: latitude,
            longitude: longitude,
            aqi: aqi,
            nickname: nickname
        )
    }
}

extension Booking {
    static let sample = Booking(
        response: BookingResponse(
            id: UUID(),
            a: BookingResponse.Location(
                id: UUID(),
                latitude: 12.9629,
                longitude: 77.5775,
                aqi: 162,
                name: "Bangalore"
            ),
            b: BookingResponse.Location(
                id: UUID(),
                latitude: 12.9635,
                longitude: 77.5789,
                aqi: 200,
                name: "Mangalore"
            ),
            price: 5000
        )
    )
}
