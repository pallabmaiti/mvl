//
//  AqiDataUseCase.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Foundation

protocol AqiDataUseCase {
    func invoke(latitude: Double, longitude: Double) async throws(MVLError) -> AqiData
}

struct AqiDataUseCaseImpl: AqiDataUseCase {
    private let repository: AqiDataRepository
    
    init(repository: AqiDataRepository) {
        self.repository = repository
    }
    
    func invoke(latitude: Double, longitude: Double) async throws(MVLError) -> AqiData {
        do {
            let response = try await repository.fetchAqiData(latitude: latitude, longitude: longitude)
            return AqiData(aqi: response.data.aqi, id: response.data.id, city: response.data.city.name)
        } catch {
            throw handleError(error)
        }
    }
}
