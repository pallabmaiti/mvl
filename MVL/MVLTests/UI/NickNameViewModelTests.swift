//
//  NickNameViewModelTests.swift
//  MVLTests
//
//  Created by Pallab Maiti on 17/04/26.
//

import MobileDesignSystem
@testable import MVL
import XCTest

@MainActor
final class NickNameViewModelTests: XCTestCase {
    func testNickNameViewModelExposesSelectedLocationDetails() {
        let selectedLocation = SelectedLocation(
            location: .mock(name: "Bangalore", aqi: 162, nickname: "Home"),
            slot: .locationA
        )
        let viewModel = buildNickNameViewModel(selectedLocation: selectedLocation).viewModel

        XCTAssertEqual(viewModel.locationName, "Bangalore")
        XCTAssertEqual(viewModel.locationAqi, "162")
        XCTAssertEqual(viewModel.locationSlot, "A")
    }

    func testNickNameViewModelConfiguresTextField() {
        let viewModel = buildNickNameViewModel().viewModel

        XCTAssertEqual(viewModel.textFieldViewModel.placeholder, "Nick Name")
        XCTAssertEqual(viewModel.textFieldViewModel.maxLength, 20)
        XCTAssertEqual(viewModel.textFieldViewModel.input, "")
    }

    func testOnAssignPassesTrimmedNicknameToCompletion() {
        var assignedNickname: String?
        let viewModel = buildNickNameViewModel { nickname in
            assignedNickname = nickname
        }.viewModel
        viewModel.textFieldViewModel.input = "  My Home  \n"

        viewModel.onAssign()

        XCTAssertEqual(assignedNickname, "My Home")
    }

    func testOnAssignPassesEmptyStringWhenInputContainsOnlyWhitespace() {
        var assignedNickname: String?
        let viewModel = buildNickNameViewModel { nickname in
            assignedNickname = nickname
        }.viewModel
        viewModel.textFieldViewModel.input = " \n "

        viewModel.onAssign()

        XCTAssertEqual(assignedNickname, "")
    }

    private func buildNickNameViewModel(
        selectedLocation: SelectedLocation = .sampleData,
        completion: @escaping (String) -> Void = { _ in }
    ) -> (viewModel: NickNameView.ViewModel, selectedLocation: SelectedLocation) {
        (
            NickNameView.ViewModel(selectedLocation: selectedLocation, completion: completion),
            selectedLocation
        )
    }
}
