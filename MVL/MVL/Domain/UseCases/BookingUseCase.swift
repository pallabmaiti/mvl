//
//  BookingUseCase.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation

protocol BookingUseCase {
    func invoke(locationA: Location, locationB: Location) async throws(MVLError) -> Booking
}

final class BookingUseCaseImpl: BookingUseCase {
    private let repository: BookingRepository
    
    init(repository: BookingRepository) {
        self.repository = repository
    }

    func invoke(locationA: Location, locationB: Location) async throws(MVLError) -> Booking {
        do {
            let response = try await repository.book(locationA: locationA, locationB: locationB)
            return Booking(response: response)
        } catch {
            throw handleError(error)
        }
    }
}
