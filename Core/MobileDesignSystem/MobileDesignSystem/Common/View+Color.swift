//
//  View+Color.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import SwiftUI

public extension View {
    func backgroundColor(_ color: MVLColor?) -> some View {
        background(color?.swiftUIColor)
    }
}
