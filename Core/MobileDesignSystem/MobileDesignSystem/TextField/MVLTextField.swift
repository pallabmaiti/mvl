//
//  MVLTextField.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 15/04/26.
//

import Combine
import SwiftUI

public struct MVLTextField: View {
    @StateObject private var viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        TextField(viewModel.placeholder, text: $viewModel.input)
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(viewModel.borderColor.swiftUIColor, lineWidth: 1)
            }
            .onChange(of: viewModel.input) { _, newValue in
                viewModel.checkMaxLength(newValue)
            }
    }
    
    public final class ViewModel: ObservableObject {
        public let placeholder: String
        public let maxLength: Int?
        @Published public var input: String = ""
        
        var borderColor: MVLColor {
            .borderColor
        }
        
        public init(placeholder: String, maxLength: Int?) {
            self.placeholder = placeholder
            self.maxLength = maxLength
        }
        
        func checkMaxLength(_ input: String) {
            guard let maxLength, input.count > maxLength else { return }
            self.input = String(input.prefix(maxLength))
        }
    }
}

#Preview {
    MVLTextField(viewModel: .init(placeholder: "Nick Name", maxLength: 20))
}
