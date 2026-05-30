//
//  ReverseGeocoderUseCase.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Foundation

protocol ReverseGeocoderUseCase {
    func invoke(latitude: Double, longitude: Double) async throws(MVLError) -> ReverseGeocode
}

struct ReverseGeocoderUseCaseImpl: ReverseGeocoderUseCase {
    private let repository: ReverseGeocoderRepository
    
    init(repository: ReverseGeocoderRepository) {
        self.repository = repository
    }

    func invoke(latitude: Double, longitude: Double) async throws(MVLError) -> ReverseGeocode {
        do {
            let response = try await repository.reverseGeocode(latitude: latitude, longitude: longitude)
            let city = response.localityInfo.administrative
                .sorted { $0.order < $1.order }
                .map { $0.name }
                .prefix(2)
                .joined(separator: ", ")
            return ReverseGeocode(
                latitude: response.latitude,
                longitude: response.longitude,
                city: city
            )
        } catch {
            throw handleError(error)
        }
    }
}
