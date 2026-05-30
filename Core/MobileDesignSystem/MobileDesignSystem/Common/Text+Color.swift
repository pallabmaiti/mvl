//
//  Text+Color.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import SwiftUI

public extension Text {
    func foregroundColor(_ color: MVLColor) -> some View {
        foregroundStyle(color.swiftUIColor)
    }
}
