//
//  SessionNetwork.swift
//  Networking
//
//  Created by Pallab Maiti on 15/04/26.
//

import Alamofire
import Foundation

public protocol SessionNetworkable: Sendable {
    func data<T: ServiceEndpoint>(for endpoint: T) async throws(NetworkError) -> T.SuccessResponse
}

public struct SessionNetwork: SessionNetworkable {
    private let session: Alamofire.Session
    private let decoder: JSONDecoder

    public init(session: Alamofire.Session = .default, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    public func data<T: ServiceEndpoint>(for endpoint: T) async throws(NetworkError) -> T.SuccessResponse {
        let result: Result<T.SuccessResponse, NetworkError> = await withCheckedContinuation { continuation in
            session.request(
                endpoint.url,
                method: HTTPMethod(rawValue: endpoint.method.rawValue),
                parameters: endpoint.body
            )
            .responseData { response in
                do {
                    if let statusCode = response.response?.statusCode,
                       (200 ..< 300).contains(statusCode) {
                        guard let data = response.data else {
                            throw NetworkError.generic(response.error ?? URLError(.zeroByteResource))
                        }

                        let successResponse = try decoder.decode(T.SuccessResponse.self, from: data)
                        continuation.resume(returning: .success(successResponse))
                        return
                    }

                    if let statusCode = response.response?.statusCode,
                       let data = response.data,
                       let failureResponse = try? decoder.decode(T.FailureResponse.self, from: data) {
                        continuation.resume(
                            returning: .failure(.failureResponse(
                                statusCode: statusCode,
                                response: failureResponse
                            ))
                        )
                        return
                    }

                    continuation.resume(returning: .failure(.generic(response.error ?? URLError(.badServerResponse))))
                } catch {
                    continuation.resume(returning: .failure(.generic(error)))
                }
            }
        }

        return try result.get()
    }
}
