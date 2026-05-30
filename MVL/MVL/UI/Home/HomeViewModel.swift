//
//  HomeViewModel.swift
//  MVL
//
//  Created by Pallab Maiti on 14/04/26.
//

import Combine
import CoreLocation
import Dispatch
import Location

extension HomeView {
    final class ViewModel: ObservableObject {
        private var cancellables: Set<AnyCancellable> = []
        private let store: Store
        
        @Published private(set) var currentLocation: Location?
        @Published private(set) var locationA: Location?
        @Published private(set) var locationB: Location?
        @Published var selectedLocation: SelectedLocation?
        @Published var isBookingPresented = false
        @Published private(set) var primaryButtonTitle: String = "Set A"
        @Published private(set) var fetchStatus: FetchStatus = .idle
        
        init(store: Store) {
            self.store = store
            bindStore()
        }
        
        let pinIcon = "icon-pin"
        
        var locationAName: String {
            locationA?.nickname ?? locationA?.name ?? "A"
        }
        
        var locationBName: String {
            locationB?.nickname ?? locationB?.name ?? "B"
        }

        var bookingViewModel: BookingView.ViewModel? {
            guard let locationA, let locationB else { return nil }
            return .init(locationA: locationA, locationB: locationB, store: store)
        }

        func updateMapCenter(_ coordinate: CLLocationCoordinate2D) {
            Task { @MainActor in
                await store.fetchAqiDataAndCurrentLocation(
                    CLLocation(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )
                )
            }
        }
        
        func onLocationA() {
            guard let locationA else { return }
            selectedLocation = SelectedLocation(location: locationA, slot: .locationA)
        }
        
        func onLocationB() {
            guard let locationB else { return }
            selectedLocation = SelectedLocation(location: locationB, slot: .locationB)
        }
        
        func onPrimaryButton() {
            if locationA == nil {
                locationA = currentLocation
                primaryButtonTitle = "Set B"
            } else if locationB == nil {
                locationB = currentLocation
                primaryButtonTitle = "Book"
            } else {
                isBookingPresented = true
            }
        }
        
        func update(nickname: String, of selectedLocation: SelectedLocation) {
            guard !nickname.isEmpty else { return }
            switch selectedLocation.slot {
            case .locationA:
                locationA = .init(id: selectedLocation.location.id, name: selectedLocation.location.name, latitude: selectedLocation.location.latitude, longitude: selectedLocation.location.longitude, aqi: selectedLocation.location.aqi, nickname: nickname)
            case .locationB:
                locationB = .init(id: selectedLocation.location.id, name: selectedLocation.location.name, latitude: selectedLocation.location.latitude, longitude: selectedLocation.location.longitude, aqi: selectedLocation.location.aqi, nickname: nickname)
            }
        }
                
        private func bindStore() {
            store.$currentLocation
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.currentLocation, on: self)
                .store(in: &cancellables)
            
            store.$fetchStatus
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.fetchStatus, on: self)
                .store(in: &cancellables)
        }
    }
}
