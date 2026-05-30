//
//  ButtonViewStyle.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import SwiftUI

struct ButtonViewStyle: ButtonStyle {
    typealias Configuration = SwiftUI.ButtonStyle.Configuration
    
    let type: ButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        return configuration
            .label
            .modifier(TextStyleModifier(style: .title1))
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .frame(maxHeight: type.size.height)
            .frame(maxWidth: .infinity, alignment: type.contentAlignment)
            .backgroundColor(type.backgroundColor)
            .cornerRadius(type.cornerRadius)
    }
}
