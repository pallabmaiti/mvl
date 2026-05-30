//
//  NetworkError.swift
//  Networking
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation

public enum NetworkError: Error, Sendable, Equatable {
    case failureResponse(statusCode: Int, response: Decodable & Sendable)
    case generic(Error)
    case missingStubbedResponse
    case responseTypeMismatch
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.failureResponse(let lhsStatusCode, _), .failureResponse(let rhsStatusCode, _)):
            return lhsStatusCode == rhsStatusCode
        case (.generic(let lhsError), .generic(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.missingStubbedResponse, .missingStubbedResponse):
            return true
        case (.responseTypeMismatch, .responseTypeMismatch):
            return true
        default:
            return false
        }
    }

}
