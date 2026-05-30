//
//  MockSessionNetwork.swift
//  NetworkingMock
//
//  Created by Pallab Maiti on 16/04/26.
//

import Foundation
import Networking

public struct NetworkRequestCapture: Sendable, Equatable {
    public let url: String
    public let method: RequestMethod

    public init(url: String, method: RequestMethod) {
        self.url = url
        self.method = method
    }
}

public actor MockSessionNetwork: SessionNetworkable {
    public typealias ResponseHandler = @Sendable (any ServiceEndpoint) throws(NetworkError) -> Any

    public var endpoint: (any ServiceEndpoint)?
    public var error: NetworkError?
    public private(set) var capturedRequests: [NetworkRequestCapture] = []

    private let responseHandler: ResponseHandler

    public init() {
        self.responseHandler = Self.missingStubbedResponse
    }

    public init(responseHandler: @escaping ResponseHandler) {
        self.responseHandler = responseHandler
    }

    public init(error: NetworkError) {
        self.responseHandler = Self.missingStubbedResponse
        self.error = error
    }

    private static func missingStubbedResponse(_ endpoint: any ServiceEndpoint) throws(NetworkError) -> Any {
        throw NetworkError.missingStubbedResponse
    }

    public func data<T: ServiceEndpoint>(for endpoint: T) async throws(NetworkError) -> T.SuccessResponse {
        self.endpoint = endpoint
        capturedRequests.append(
            NetworkRequestCapture(url: endpoint.url, method: endpoint.method)
        )

        if let error {
            throw error
        }

        let response = try responseHandler(endpoint)

        guard let typedResponse = response as? T.SuccessResponse else {
            throw NetworkError.responseTypeMismatch
        }

        return typedResponse
    }
}
