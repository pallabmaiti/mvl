//
//  MVLError.swift
//  MVL
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation
import Networking

struct MVLError: Error {
    let localizedDescription: String
    
    init(localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }
}

func handleError(_ error: Error) -> MVLError {
    var         localizedDescription: String
    if let error = error as? NetworkError {
        switch error {
        case let .failureResponse(_, response):
            switch response {
            case let response as AqiDataFailureResponse:
                        localizedDescription = response.message
            case let response as ReverseGeocodeFailureResponse:
                        localizedDescription = response.description
            default:
                        localizedDescription = "Something went wrong"
            }
        case let .generic(error):
                    localizedDescription = error.localizedDescription
        case .missingStubbedResponse:
                    localizedDescription = "Missing stubbed response"
        case .responseTypeMismatch:
                    localizedDescription = "Response type mismatch"
        }
    } else {
        localizedDescription = error.localizedDescription
    }
    
    return MVLError(localizedDescription: localizedDescription)
}
