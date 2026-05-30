//
//  Networking.swift
//  Networking
//
//  Created by Pallab Maiti on 14/04/26.
//

import Foundation

public actor Networking {
    private let sessionNetwork: SessionNetworkable
    
    public init(sessionNetwork: SessionNetworkable = SessionNetwork()) {
        self.sessionNetwork = sessionNetwork
    }
    
    public func fetch<T: ServiceEndpoint>(_ endpoint: T) async throws(NetworkError) -> T.SuccessResponse {
        try await sessionNetwork.data(for: endpoint)
    }
}
