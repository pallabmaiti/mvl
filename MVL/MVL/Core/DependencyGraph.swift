//
//  DependencyGraph.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Location
import Networking

struct ExternalDependencies {
    let networking: Networking
    let locationService: LocationService
}

protocol RepositoriesProvider {
    var aqiDataRepository: AqiDataRepository { get }
    var reverseGeocoderRepository: ReverseGeocoderRepository { get }
    var bookingRepository: BookingRepository { get }
    var bookingListRepository: BookingListRepository { get }
}

final class RepositoriesProviderImpl: RepositoriesProvider {
    private let externalDependencies: ExternalDependencies
    
    init(externalDependencies: ExternalDependencies) {
        self.externalDependencies = externalDependencies
    }
    
    var aqiDataRepository: AqiDataRepository {
        AqiDataRepositoryImpl(networking: externalDependencies.networking)
    }
    
    var reverseGeocoderRepository: ReverseGeocoderRepository {
        ReverseGeocoderRepositoryImpl(networking: externalDependencies.networking)
    }
    
    var bookingRepository: BookingRepository {
        BookingRepositoryImpl()
    }
    
    var bookingListRepository: BookingListRepository {
        BookingListRepositoryImpl()
    }
}

protocol UseCasesProvider {
    var aqiDataUseCase: AqiDataUseCase { get }
    var reverseGeocoderUseCase: ReverseGeocoderUseCase { get }
    var bookingUseCase: BookingUseCase { get }
    var bookingListUseCase: BookingListUseCase { get }
}

final class UseCasesProviderImpl: UseCasesProvider {
    private let repositories: RepositoriesProvider
    
    init(repositories: RepositoriesProvider) {
        self.repositories = repositories
    }
    
    var aqiDataUseCase: AqiDataUseCase {
        AqiDataUseCaseImpl(repository: repositories.aqiDataRepository)
    }
    
    var reverseGeocoderUseCase: ReverseGeocoderUseCase {
        ReverseGeocoderUseCaseImpl(repository: repositories.reverseGeocoderRepository)
    }
    
    var bookingUseCase: BookingUseCase {
        BookingUseCaseImpl(repository: repositories.bookingRepository)
    }
    
    var bookingListUseCase: BookingListUseCase {
        BookingListUseCaseImpl(repository: repositories.bookingListRepository)
    }
}

protocol DependencyGraph {
    var repositories: RepositoriesProvider { get }
    var useCases: UseCasesProvider { get }
}

final class DependencyGraphImpl: DependencyGraph {
    let repositories: RepositoriesProvider
    let useCases: UseCasesProvider
    
    init(dependencies: ExternalDependencies) {
        self.repositories = RepositoriesProviderImpl(externalDependencies: dependencies)
        self.useCases = UseCasesProviderImpl(repositories: repositories)
    }
}
