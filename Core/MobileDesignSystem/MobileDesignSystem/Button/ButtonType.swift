//
//  ButtonType.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import Foundation
import SwiftUI
import UIKit

public enum ButtonType: Int {
    case primary
    case secondary
    case primaryVariant
    
    public var size: CGSize {
        switch self {
        case .primary:
            CGSize(width: Double.infinity, height: 64)
        case .secondary:
            CGSize(width: Double.infinity, height: 64)
        case .primaryVariant:
            CGSize(width: Double.infinity, height: 136)
        }
    }
    
    public var backgroundColor: MVLColor {
        switch self {
        case .primary:
            return MVLColor.primaryButtonBackground
        case .secondary:
            return MVLColor.secondaryButtonBackground
        case .primaryVariant:
            return MVLColor.primaryButtonBackground
        }
    }
    
    public var cornerRadius: CGFloat {
        switch self {
        case .primary:
            return 8
        case .secondary:
            return 8
        case .primaryVariant:
            return 8
        }
    }
        
    public var contentAlignment: Alignment {
        switch self {
        case .secondary:
            return .leading
        case .primary, .primaryVariant:
            return .center
        }
    }
}
