//
//  BookingView.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import MobileDesignSystem
import SwiftUI

struct BookingView: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        if let booking = viewModel.booking {
            VStack {
                LocationView(
                    locationSlot: .locationA,
                    locationName: viewModel.locationAName,
                    locationAqi: viewModel.locationAAqi,
                    locationNickname: viewModel.locationANickname
                )
                
                Divider()
                    .padding(.vertical, 8)
                
                LocationView(
                    locationSlot: .locationB,
                    locationName: viewModel.locationBName,
                    locationAqi: viewModel.locationBAqi,
                    locationNickname: viewModel.locationBNickname
                )
                
                Spacer()
                
                HStack {
                    MVLText(text: "price", style: .largeTitle, type: .secondary)
                    Spacer()
                    MVLText(text: booking.price.description, style: .largeTitle, type: .primary)
                }
                .padding(.bottom, 20)
                
                MVLButton(title: "My Bookings", type: .primary, action: viewModel.showBookings)
            }
            .padding()
            .fullScreenCover(isPresented: $viewModel.isBookingListPresented) {
                BookingListView(viewModel: viewModel.bookingListViewModel)
            }
        } else if case let .failure(errorDescription) = viewModel.fetchStatus {
            MVLText(text: errorDescription, style: .largeTitle, type: .primary)
                .padding()
        } else {
            ProgressView()
                .task {
                    viewModel.book()
                }
        }
    }
}

extension BookingView {
    private struct LocationView: View {
        let locationSlot: SelectedLocation.Slot
        let locationName: String
        let locationAqi: String
        let locationNickname: String?
        
        var body: some View {
            HStack(alignment: .top, spacing: 28) {
                MVLText(text: locationSlot.rawValue, style: .largeTitle, type: .primary)
                VStack(alignment: .leading, spacing: 16) {
                    MVLText(text: locationName, style: .largeTitle, type: .primary)
                    HStack {
                        MVLText(text: "aqi", type: .secondary)
                        Spacer()
                        MVLText(text: locationAqi, type: .primary)
                        Spacer()
                    }
                    
                    if let locationNickname {
                        HStack {
                            MVLText(text: "nickname", type: .secondary)
                            Spacer()
                            MVLText(text: locationNickname, type: .primary)
                            Spacer()
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    BookingView(
        viewModel: .init(
            locationA: .sampleData,
            locationB: .sampleData,
            store: .mock
        )
    )
}
