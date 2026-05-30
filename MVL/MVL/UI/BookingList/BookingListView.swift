//
//  BookingListView.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import MobileDesignSystem
import SwiftUI

struct BookingListView: View {
    @StateObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        if let bookings = viewModel.bookings {
            HeaderView(viewModel: viewModel)
            ListView(bookings: bookings)
        } else if case let .failure(errorDescription) = viewModel.fetchStatus {
            MVLText(text: errorDescription, style: .largeTitle, type: .primary)
                .padding()
        } else {
            ProgressView()
                .task {
                    viewModel.fetchBookings()
                }
        }
    }
}

extension BookingListView {
    private struct HeaderView: View {
        @ObservedObject var viewModel: ViewModel
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 16) {
                        MVLText(text: "Total Count", style: .title2, type: .secondary)
                        MVLText(text: viewModel.totalBookings.description, style: .title2, type: .primary)
                    }
                    Spacer()
                    VStack(spacing: 16) {
                        MVLText(text: "Total Price", style: .title2, type: .secondary)
                        MVLText(text: viewModel.totalPrice.description, style: .title2, type: .primary)
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 0))
                    .frame(maxHeight: 8)
                    .backgroundColor(.borderColor)
            }
        }
    }
}

extension BookingListView {
    private struct ListView: View {
        let bookings: [Booking]
        
        var body: some View {
            List(bookings, id: \.id) { booking in
                ItemView(booking: booking)
            }
            .listStyle(.plain)
        }
    }
}

extension BookingListView {
    private struct ItemView: View {
        let booking: Booking
        
        var body: some View {
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    MVLText(text: SelectedLocation.Slot.locationA.rawValue, style: .title2, type: .primary)
                    MVLText(text: booking.a.name, style: .title2, type: .primary)
                }
                HStack(spacing: 16) {
                    MVLText(text: SelectedLocation.Slot.locationB.rawValue, style: .title2, type: .primary)
                    MVLText(text: booking.b.name, style: .title2, type: .primary)
                }
            }
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    BookingListView(viewModel: .init(store: .mock))
}
