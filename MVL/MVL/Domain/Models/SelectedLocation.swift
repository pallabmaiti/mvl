//
//  SelectedLocation.swift
//  MVL
//
//  Created by Pallab Maiti on 15/04/26.
//

import Foundation

nonisolated struct SelectedLocation: Codable, Hashable, Identifiable {
    enum Slot: String, Codable, Hashable {
        case locationA = "A"
        case locationB = "B"
    }
    var id: String { "\(location.id)-\(slot.rawValue)" }
    let location: Location
    let slot: Slot
    
    static let sampleData = SelectedLocation(location: .sampleData, slot: .locationA)
}
