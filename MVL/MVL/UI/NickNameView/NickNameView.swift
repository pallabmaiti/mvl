//
//  NickNameView.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import MobileDesignSystem
import SwiftUI

struct NickNameView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack {
            HStack(alignment: .top, spacing: 28) {
                MVLText(text: viewModel.locationSlot, style: .largeTitle, type: .primary)
                VStack(alignment: .leading, spacing: 20) {
                    MVLText(text: viewModel.locationName, style: .largeTitle, type: .primary)
                    HStack {
                        MVLText(text: "aqi", type: .secondary)
                        Spacer()
                        MVLText(text: viewModel.locationAqi, type: .primary)
                        Spacer()
                    }
                }
                Spacer()
            }
            Spacer()
            
            MVLTextField(viewModel: viewModel.textFieldViewModel)
                .padding(.bottom, 20)
            
            MVLButton(
                title: "Assign",
                type: .primary,
                action: {
                    dismiss()
                    viewModel.onAssign()
                }
            )
        }
        .padding()
    }
}

#Preview {
    NickNameView(
        viewModel: .init(
            selectedLocation: .sampleData,
            completion: { _ in }
        )
    )
}
