//
//  BookingListUseCase.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation

protocol BookingListUseCase {
    func invoke(year: Int, month: Int) async throws(MVLError) -> [Booking]
}

final class BookingListUseCaseImpl: BookingListUseCase {
    private let repository: BookingListRepository
    
    init(repository: BookingListRepository) {
        self.repository = repository
    }

    func invoke(year: Int, month: Int) async throws(MVLError) -> [Booking] {
        do {
            let response = try await repository.fetchBookingList(year: year, month: month)
            return response.map{ Booking(response: $0) }
        } catch {
            throw handleError(error)
        }
    }
}
