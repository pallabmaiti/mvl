//
//  TextStyle.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import SwiftUI

public extension MVLFont {
    class func font(forTextStyle style: UIFont.TextStyle) -> Font {
        Font.system(size: size(forTextStyle: style), weight: weight(forTextStyle: style))
    }
    
    class func foregroundColor(forTextStyle style: UIFont.TextStyle) -> UIColor {
        return MVLColor.primaryButtonTitle.value
    }
}

public struct TextStyleModifier: ViewModifier {
    public var style: UIFont.TextStyle
    
    public func body(content: Content) -> some View {
        content
            .font(MVLFont.font(forTextStyle: style))
            .foregroundStyle(SwiftUI.Color(MVLFont.foregroundColor(forTextStyle: style)))
    }
}
