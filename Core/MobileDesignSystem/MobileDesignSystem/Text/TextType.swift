//
//  TextType.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import UIKit

public enum TextType: Int {
    case primary
    case secondary
        
    public var foregroundColor: MVLColor {
        switch self {
        case .primary:
            return MVLColor.primaryText
        case .secondary:
            return MVLColor.secondaryText
        }
    }
}
