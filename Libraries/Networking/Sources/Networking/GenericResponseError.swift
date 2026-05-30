//
//  GenericResponseError.swift
//  Networking
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation

public struct GenericResponseError: Decodable, Error {
    public let message: String
    public let StatusCode: Int
}
