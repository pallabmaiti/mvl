//
//  MockNetworking.swift
//  Networking
//
//  Created by Pallab Maiti on 16/04/26.
//

import Networking

public extension Networking {
    static var mock: Networking {
        Networking(sessionNetwork: MockSessionNetwork())
    }

    static func mock(
        responseHandler: @escaping MockSessionNetwork.ResponseHandler
    ) -> Networking {
        Networking(sessionNetwork: MockSessionNetwork(responseHandler: responseHandler))
    }

    static func mock(error: NetworkError) -> Networking {
        Networking(sessionNetwork: MockSessionNetwork(error: error))
    }
}
