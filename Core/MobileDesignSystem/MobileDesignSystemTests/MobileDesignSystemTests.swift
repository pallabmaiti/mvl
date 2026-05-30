//
//  MobileDesignSystemTests.swift
//  MobileDesignSystemTests
//
//  Created by Pallab Maiti on 16/04/26.
//

@testable import MobileDesignSystem
import SwiftUI
import UIKit
import XCTest

final class MobileDesignSystemTests: XCTestCase {
    func testTextFieldViewModelStoresPlaceholderAndMaxLength() {
        let viewModel = MVLTextField.ViewModel(placeholder: "Nick Name", maxLength: 20)

        XCTAssertEqual(viewModel.placeholder, "Nick Name")
        XCTAssertEqual(viewModel.maxLength, 20)
        XCTAssertEqual(viewModel.input, "")
    }

    func testTextFieldViewModelTruncatesInputBeyondMaxLength() {
        let viewModel = MVLTextField.ViewModel(placeholder: "Nick Name", maxLength: 5)

        viewModel.input = "LongerThanFive"
        viewModel.checkMaxLength(viewModel.input)

        XCTAssertEqual(viewModel.input, "Longe")
    }

    func testTextFieldViewModelDoesNotChangeInputWithinMaxLength() {
        let viewModel = MVLTextField.ViewModel(placeholder: "Nick Name", maxLength: 20)

        viewModel.input = "Home"
        viewModel.checkMaxLength(viewModel.input)

        XCTAssertEqual(viewModel.input, "Home")
    }

    func testTextFieldViewModelDoesNotChangeInputAtExactMaxLength() {
        let viewModel = MVLTextField.ViewModel(placeholder: "Nick Name", maxLength: 4)

        viewModel.input = "Home"
        viewModel.checkMaxLength(viewModel.input)

        XCTAssertEqual(viewModel.input, "Home")
    }

    func testTextFieldViewModelDoesNotTruncateWhenMaxLengthIsNil() {
        let viewModel = MVLTextField.ViewModel(placeholder: "Nick Name", maxLength: nil)

        viewModel.input = "Longer Than Default"
        viewModel.checkMaxLength(viewModel.input)

        XCTAssertEqual(viewModel.input, "Longer Than Default")
    }

    func testButtonTypePrimaryConfiguration() {
        XCTAssertEqual(ButtonType.primary.size.height, 64)
        XCTAssertEqual(ButtonType.primary.backgroundColor, .primaryButtonBackground)
        XCTAssertEqual(ButtonType.primary.cornerRadius, 8)
        XCTAssertEqual(ButtonType.primary.contentAlignment, .center)
        XCTAssertTrue(ButtonType.primary.size.width.isInfinite)
    }

    func testButtonTypeSecondaryConfiguration() {
        XCTAssertEqual(ButtonType.secondary.size.height, 64)
        XCTAssertEqual(ButtonType.secondary.backgroundColor, .secondaryButtonBackground)
        XCTAssertEqual(ButtonType.secondary.cornerRadius, 8)
        XCTAssertEqual(ButtonType.secondary.contentAlignment, .leading)
        XCTAssertTrue(ButtonType.secondary.size.width.isInfinite)
    }

    func testButtonTypePrimaryVariantConfiguration() {
        XCTAssertEqual(ButtonType.primaryVariant.size.height, 136)
        XCTAssertEqual(ButtonType.primaryVariant.backgroundColor, .primaryButtonBackground)
        XCTAssertEqual(ButtonType.primaryVariant.cornerRadius, 8)
        XCTAssertEqual(ButtonType.primaryVariant.contentAlignment, .center)
        XCTAssertTrue(ButtonType.primaryVariant.size.width.isInfinite)
    }

    func testTextTypeForegroundColors() {
        XCTAssertEqual(TextType.primary.foregroundColor, .primaryText)
        XCTAssertEqual(TextType.secondary.foregroundColor, .secondaryText)
    }

    func testMVLColorValuesMatchExpectedPalette() {
        assertColor(MVLColor.primaryButtonBackground.value, equals: MVLColor.BaseColor.yellow)
        assertColor(MVLColor.secondaryButtonBackground.value, equals: MVLColor.BaseColor.gray1)
        assertColor(MVLColor.primaryButtonTitle.value, equals: MVLColor.BaseColor.black)
        assertColor(MVLColor.secondaryButtonTitle.value, equals: MVLColor.BaseColor.black)
        assertColor(MVLColor.primaryText.value, equals: MVLColor.BaseColor.black)
        assertColor(MVLColor.secondaryText.value, equals: MVLColor.BaseColor.gray2)
        assertColor(MVLColor.borderColor.value, equals: MVLColor.BaseColor.gray3)
    }

    func testMVLColorSwiftUIColorIsCreatedForEveryToken() {
        for color in MVLColor.allCases {
            _ = color.swiftUIColor
        }
    }

    func testMVLFontSizeMappings() {
        XCTAssertEqual(MVLFont.size(forTextStyle: .largeTitle), 24)
        XCTAssertEqual(MVLFont.size(forTextStyle: .title1), 20)
        XCTAssertEqual(MVLFont.size(forTextStyle: .title2), 18)
        XCTAssertEqual(MVLFont.size(forTextStyle: .body), 18)
    }

    func testMVLFontWeightMappings() {
        XCTAssertEqual(MVLFont.weight(forTextStyle: .largeTitle), .bold)
        XCTAssertEqual(MVLFont.weight(forTextStyle: .title1), .bold)
        XCTAssertEqual(MVLFont.weight(forTextStyle: .title2), .bold)
        XCTAssertEqual(MVLFont.weight(forTextStyle: .body), .regular)
    }

    func testMVLFontForegroundColorUsesPrimaryButtonTitleColor() {
        assertColor(MVLFont.foregroundColor(forTextStyle: .body), equals: MVLColor.primaryButtonTitle.value)
    }

    private func assertColor(_ lhs: UIColor, equals rhs: UIColor, file: StaticString = #filePath, line: UInt = #line) {
        var lhsRed: CGFloat = 0
        var lhsGreen: CGFloat = 0
        var lhsBlue: CGFloat = 0
        var lhsAlpha: CGFloat = 0
        var rhsRed: CGFloat = 0
        var rhsGreen: CGFloat = 0
        var rhsBlue: CGFloat = 0
        var rhsAlpha: CGFloat = 0

        XCTAssertTrue(lhs.getRed(&lhsRed, green: &lhsGreen, blue: &lhsBlue, alpha: &lhsAlpha), file: file, line: line)
        XCTAssertTrue(rhs.getRed(&rhsRed, green: &rhsGreen, blue: &rhsBlue, alpha: &rhsAlpha), file: file, line: line)

        XCTAssertEqual(lhsRed, rhsRed, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(lhsGreen, rhsGreen, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(lhsBlue, rhsBlue, accuracy: 0.0001, file: file, line: line)
        XCTAssertEqual(lhsAlpha, rhsAlpha, accuracy: 0.0001, file: file, line: line)
    }
}
