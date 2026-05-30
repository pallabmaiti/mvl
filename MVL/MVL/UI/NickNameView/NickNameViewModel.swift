//
//  NickNameViewModel.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Combine
import Foundation
import MobileDesignSystem

extension NickNameView {
    final class ViewModel: ObservableObject {
        private let selectedLocation: SelectedLocation
        private let completion: (String) -> Void
        let textFieldViewModel: MVLTextField.ViewModel
        
        init(selectedLocation: SelectedLocation, completion: @escaping (String) -> Void) {
            self.selectedLocation = selectedLocation
            self.completion = completion
            self.textFieldViewModel = .init(placeholder: "Nick Name", maxLength: 20)
        }
        
        var locationName: String {
            selectedLocation.location.name
        }
        
        var locationAqi: String {
            selectedLocation.location.aqi.description
        }
        
        var locationSlot: String {
            selectedLocation.slot.rawValue
        }
        
        func onAssign() {
            completion(textFieldViewModel.input.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
