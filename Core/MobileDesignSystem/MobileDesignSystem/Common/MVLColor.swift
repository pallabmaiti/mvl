//
//  Color.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import Foundation
import SwiftUI

public enum MVLColor: String, CaseIterable {
    // Button
    case primaryButtonBackground
    case secondaryButtonBackground
    case primaryButtonTitle
    case secondaryButtonTitle
    
    // Label
    case primaryText
    case secondaryText
    
    case borderColor
    
    public var swiftUIColor: SwiftUI.Color {
        SwiftUI.Color(value)
    }
}
