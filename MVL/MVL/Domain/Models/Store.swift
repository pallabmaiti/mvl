//
//  Store.swift
//  MVL
//
//  Created by Pallab Maiti on 14/04/26.
//

import Combine
import CoreLocation
import Location
import LocationMock
import MapKit
import Networking

final class Store: ObservableObject {
    private let locationService: LocationService
    private let aqiDataUseCase: AqiDataUseCase
    private let reverseGeocoderUseCase: ReverseGeocoderUseCase
    private let bookingUseCase: BookingUseCase
    private let bookingListUseCase: BookingListUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private(set) var currentLocation: Location?
    @Published private(set) var booking: Booking?
    @Published private(set) var bookings: [Booking]?
    @Published private(set) var fetchStatus: FetchStatus = .idle
    
    init(
        locationService: LocationService,
        aqiDataUseCase: AqiDataUseCase,
        reverseGeocodingUseCase: ReverseGeocoderUseCase,
        bookingUseCase: BookingUseCase,
        bookingListUseCase: BookingListUseCase
    ) {
        self.locationService = locationService
        self.aqiDataUseCase = aqiDataUseCase
        self.reverseGeocoderUseCase = reverseGeocodingUseCase
        self.bookingUseCase = bookingUseCase
        self.bookingListUseCase = bookingListUseCase
        self.addObservers()
        self.requestLocationAccessIfNeeded()
    }
    
    func fetchAqiDataAndCurrentLocation(_ location: CLLocation) async {
        do {
            fetchStatus = .loading
            let reverseGeocode = try await reverseGeocodeLocation(location)
            let aqiData = try await aqiDataUseCase.invoke(
                latitude: reverseGeocode.latitude,
                longitude: reverseGeocode.longitude
            )
            updateCurrentLocation(location: location, reverseGeocode: reverseGeocode, aqiData: aqiData)
            fetchStatus = .success
        } catch {
            fetchStatus = .failure(error.localizedDescription)
        }
    }
    
    func book(locationA: Location, locationB: Location) async {
        do {
            fetchStatus = .loading
            let response = try await bookingUseCase.invoke(locationA: locationA, locationB: locationB)
            self.booking = response
            fetchStatus = .success
        } catch {
            fetchStatus = .failure(error.localizedDescription)
        }
    }
    
    func fetchBookings(year: Int, month: Int) async {
        do {
            fetchStatus = .loading
            self.bookings = try await bookingListUseCase.invoke(year: year, month: month)
            fetchStatus = .success
        } catch {
            fetchStatus = .failure(error.localizedDescription)
        }
    }

    private func updateCurrentLocation(
        location: CLLocation,
        reverseGeocode: ReverseGeocode,
        aqiData: AqiData
    ) {
        currentLocation = Location(
            id: UUID(),
            name: reverseGeocode.city,
            latitude:         location.coordinate.latitude,
            longitude:         location.coordinate.longitude,
            aqi: aqiData.aqi,
            nickname: nil
        )
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation) async throws(MVLError) -> ReverseGeocode {
        return try await reverseGeocoderUseCase.invoke(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    private func addObservers() {
        locationService.locationSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] location in
                guard let self, let location else { return }
                Task { @MainActor in
                    await self.fetchAqiDataAndCurrentLocation(location)
                }
            })
            .store(in: &cancellables)
    }

    private func requestLocationAccessIfNeeded() {
        if locationService.isAuthorized {
            locationService.startUpdatingLocation()
            return
        }

        locationService.requestWhenInUseAuthorization()
    }
}

enum FetchStatus: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

extension Store {
    static let mock = Store(
        locationService: MockLocationService(),
        aqiDataUseCase: AqiDataUseCaseImpl(
            repository: MockAqiDataRepositoryImpl(result: .success(.sampleData))
        ),
        reverseGeocodingUseCase: ReverseGeocoderUseCaseImpl(
            repository: MockReverseGeocoderRepositoryImpl(response: .success(.sampleData))
        ),
        bookingUseCase: BookingUseCaseImpl(
            repository: MockBookingRepositoryImpl(result: .success(.sampleData))
        ),
        bookingListUseCase: BookingListUseCaseImpl(
            repository: MockBookingListRepositoryImpl(result: .success([.sampleData, .sampleData]))
        )
    )
}
