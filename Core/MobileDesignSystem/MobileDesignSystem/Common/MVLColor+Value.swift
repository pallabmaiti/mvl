//
//  MVLColor+Value.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import SwiftUI

public extension MVLColor {
    enum BaseColor {
        public static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        public static let black = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        public static let yellow = #colorLiteral(red: 1, green: 0.768627451, blue: 0, alpha: 1)
        public static let gray1 = #colorLiteral(red: 0.9490196078, green: 0.9607843137, blue: 0.968627451, alpha: 1)
        public static let gray2 = #colorLiteral(red: 0.4039215686, green: 0.4117647059, blue: 0.4156862745, alpha: 1)
        public static let gray3 = #colorLiteral(red: 0.8509803922, green: 0.8666666667, blue: 0.8784313725, alpha: 1)
    }
    
    var value: UIColor {
        switch self {
        // Button
        case .primaryButtonBackground:
            return BaseColor.yellow
        case .secondaryButtonBackground:
            return BaseColor.gray1
        case .primaryButtonTitle:
            return BaseColor.black
        case .secondaryButtonTitle:
            return BaseColor.black
            
        // Label
        case .primaryText:
            return BaseColor.black
        case .secondaryText:
            return BaseColor.gray2
            
        case .borderColor:
            return BaseColor.gray3
        }
    }
}
