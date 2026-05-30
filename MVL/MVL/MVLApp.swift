//
//  MVLApp.swift
//  MVL
//
//  Created by Pallab Maiti on 14/04/26.
//

import Location
import Networking
import SwiftUI

@main
struct MVLApp: App {
    private let dependencyGraph: DependencyGraph
    private let store: Store
    
    init() {
        let dependencies = ExternalDependencies(
            networking: Networking(),
            locationService: LocationServiceImpl(),
        )
        dependencyGraph = DependencyGraphImpl(
            dependencies: dependencies
        )
        store = Store(
            locationService: dependencies.locationService,
            aqiDataUseCase: dependencyGraph.useCases.aqiDataUseCase,
            reverseGeocodingUseCase: dependencyGraph.useCases.reverseGeocoderUseCase,
            bookingUseCase: dependencyGraph.useCases.bookingUseCase,
            bookingListUseCase: dependencyGraph.useCases.bookingListUseCase
        )
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: .init(store: store))
        }
    }
}
