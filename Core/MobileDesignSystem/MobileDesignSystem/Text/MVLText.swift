//
//  MVLText.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import SwiftUI

public struct MVLText: View {
    private let text: String
    private let style: UIFont.TextStyle
    private let type: TextType
    
    public init(text: String, style: UIFont.TextStyle = .title2, type: TextType) {
        self.text = text
        self.style = style
        self.type = type
    }
    
    public var body: some View {
        Text(text)
            .font(MVLFont.font(forTextStyle: style))
            .foregroundColor(type.foregroundColor)
    }
}

#Preview {
    MVLText(text: "ABC", type: .primary)
}
