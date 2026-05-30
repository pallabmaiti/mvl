//
//  HomeView.swift
//  MVL
//
//  Created by Pallab Maiti on 14/04/26.
//

import Location
import MapKit
import MobileDesignSystem
import Networking
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: HomeView.ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
        
    var body: some View {
        if let location = viewModel.currentLocation {
            VStack {
                HeaderView(viewModel: viewModel, location: location)
                MapView(viewModel: viewModel, location: location)
                ButtonView(viewModel: viewModel)
            }
            .fullScreenCover(item: $viewModel.selectedLocation) { location in
                NickNameView(viewModel: .init(selectedLocation: location, completion: { nickname in
                    viewModel.update(nickname: nickname, of: location)
                }))
            }
            .fullScreenCover(isPresented: $viewModel.isBookingPresented) {
                if let bookingViewModel = viewModel.bookingViewModel {
                    BookingView(viewModel: bookingViewModel)
                } else {
                    ProgressView()
                }
            }
        } else if case let .failure(errorDescription) = viewModel.fetchStatus {
            MVLText(text: errorDescription, style: .largeTitle, type: .primary)
                .padding()
        } else {
            ProgressView()
        }
    }
    
}

extension HomeView {
    private struct HeaderView: View {
        @ObservedObject var viewModel: ViewModel
        let location: Location
        var body: some View {
            HStack {
                Spacer()
                MVLText(text: "aqi", type: .secondary)
                MVLText(text: String(location.aqi), type: .primary)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
        }
    }
}

extension HomeView {
    private struct MapView: View {
        @ObservedObject var viewModel: ViewModel
        let location: Location
        @State private var mapPosition: MapCameraPosition = .automatic

        var body: some View {
            ZStack {
                Map(position: $mapPosition)
                    .onMapCameraChange(frequency: .onEnd) { context in
                        viewModel.updateMapCenter(context.region.center)
                    }
                    .onAppear {
                        mapPosition = position(for: location)
                    }
                    .onChange(of: location) { _, newLocation in
                        mapPosition = position(for: newLocation)
                    }
                
                VStack {
                    Image(viewModel.pinIcon)
                        .resizable()
                        .frame(width: 32, height: 54)
                        .allowsHitTesting(false)
                }
            }
        }
        
        private func position(for location: Location) -> MapCameraPosition {
            .region(
                MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 250,
                    longitudinalMeters: 250
                )
            )
        }
    }
}

extension HomeView {
    private struct ButtonView: View {
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            HStack {
                VStack {
                    MVLButton(
                        title: viewModel.locationAName,
                        type: .secondary,
                        action: viewModel.onLocationA
                    )
                    MVLButton(
                        title: viewModel.locationBName,
                        type: .secondary,
                        action: viewModel.onLocationB
                    )
                }
                MVLButton(
                    title: viewModel.primaryButtonTitle,
                    type: .primaryVariant,
                    action: viewModel.onPrimaryButton
                )
                .frame(width: 96)
            }
            .padding()
        }
    }
}

#Preview {
    HomeView(
        viewModel: .init(
            store: .mock
        )
    )
}
