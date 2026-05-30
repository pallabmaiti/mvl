//
//  Font.swift
//  MobileDesignSystem
//
//  Created by Pallab Maiti on 14/04/26.
//

import UIKit
import SwiftUI

public class MVLFont: UIFont, @unchecked Sendable {
    public class func size(forTextStyle style: UIFont.TextStyle) -> CGFloat {
        switch style {
        case .largeTitle: return 24
        case .title1: return 20
        case .title2: return 18
        default: return 18
        }
    }
    
    public class func weight(forTextStyle style: UIFont.TextStyle) -> Font.Weight {
        switch style {
        case .largeTitle, .title1, .title2: return .bold
        default: return .regular
        }
    }
}
