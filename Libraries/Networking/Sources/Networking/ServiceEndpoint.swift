//
//  ServiceEndpoint.swift
//  Networking
//
//  Created by Pallab Maiti on 14/04/26.
//

public protocol ServiceEndpoint: Sendable {
    associatedtype Body: Encodable & Sendable
    associatedtype SuccessResponse: Decodable & Sendable
    associatedtype FailureResponse: Decodable & Sendable
    var body: Body? { get }
    var method: RequestMethod { get }
    var baseURL: String { get }
    var path: String { get }
}

public extension ServiceEndpoint {
    var url: String {
        "\(baseURL)\(path)"
    }
}
