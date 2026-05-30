//
//  MVLButton.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import SwiftUI

public struct MVLButton: View {
    private let title: String
    private let type: ButtonType
    private let action: () -> Void
    
    public init(title: String, type: ButtonType, action: @escaping () -> Void) {
        self.title = title
        self.type = type
        self.action = action
    }
    
    public var body: some View {
        Button(title, action: action)
            .buttonStyle(ButtonViewStyle(type: type))
    }
}

#Preview {
    MVLButton(title: "Ok", type: .primary, action: {})
}
