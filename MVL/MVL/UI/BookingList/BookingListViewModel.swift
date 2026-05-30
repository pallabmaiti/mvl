//
//  BookingListViewModel.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Combine
import Dispatch
import Foundation

extension BookingListView {
    final class ViewModel: ObservableObject {
        private let store: Store
        private var cancellables: Set<AnyCancellable> = []

        @Published private(set) var bookings: [Booking]?
        @Published private(set) var fetchStatus: FetchStatus = .idle

        init(store: Store) {
            self.store = store
            bindStore()
        }
        
        var totalBookings: Int {
            bookings?.count ?? 0
        }
        
        var totalPrice: Double {
            bookings?.reduce(0) { $0 + $1.price } ?? 0
        }
        
        func fetchBookings() {
            Task { @MainActor in
                let date = Calendar.current.dateComponents([.year, .month], from: Date())
                guard let year = date.year, let month = date.month else { return }
                await store.fetchBookings(year: year, month: month)
            }
        }
        
        private func bindStore() {
            store.$bookings
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.bookings, on: self)
                .store(in: &cancellables)
            
            store.$fetchStatus
                .receive(on: DispatchQueue.main)
                .assign(to: \.self.fetchStatus, on: self)
                .store(in: &cancellables)
        }
    }
}
