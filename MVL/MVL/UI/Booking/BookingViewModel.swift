//
//  BookingViewModel.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Combine
import Dispatch

extension BookingView {
    final class ViewModel: ObservableObject {
        private let locationA: Location
        private let locationB: Location
        private let store: Store
        private var cancellables: Set<AnyCancellable> = []

        @Published private(set) var booking: Booking?
        @Published var isBookingListPresented = false
        @Published private(set) var fetchStatus: FetchStatus = .idle

        init(locationA: Location, locationB: Location, store: Store) {
            self.locationA = locationA
            self.locationB = locationB
            self.store = store
            bindStore()
        }
        
        var locationAName: String { locationA.name }
        var locationANickname: String? { locationA.nickname }
        var locationAAqi: String { locationA.aqi.description }
        
        var locationBName: String { locationB.name }
        var locationBNickname: String? { locationB.nickname }
        var locationBAqi: String { locationB.aqi.description }
        
        var bookingListViewModel: BookingListView.ViewModel {
            return .init(store: store)
        }

        func book() {
            Task { @MainActor in
                await store.book(locationA: locationA, locationB: locationB)
            }
        }
        
        func showBookings() {
            isBookingListPresented = true
        }
        
        private func bindStore() {
            store.$booking
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.booking, on: self)
                .store(in: &cancellables)
            
            store.$fetchStatus
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.fetchStatus, on: self)
                .store(in: &cancellables)
        }
    }
}
