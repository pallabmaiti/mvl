//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by Pallab Maiti on 16/04/26.
//

import Alamofire
@testable import Networking
import NetworkingMock
import XCTest

final class NetworkingTests: XCTestCase {
    func testRequestMethodRawValues() {
        XCTAssertEqual(RequestMethod.get.rawValue, "GET")
        XCTAssertEqual(RequestMethod.post.rawValue, "POST")
        XCTAssertEqual(RequestMethod.put.rawValue, "PUT")
        XCTAssertEqual(RequestMethod.delete.rawValue, "DELETE")
    }

    func testServiceEndpointBuildsURLFromBaseURLAndPath() {
        XCTAssertEqual(TestEndpoint().url, "https://example.com/air-quality")
    }

    func testMockSessionNetworkReturnsStubbedResponse() async throws {
        let expectedResponse = TestResponse(value: "ok")
        let mockSessionNetwork = MockSessionNetwork { _ in
            expectedResponse
        }

        let response: TestResponse = try await mockSessionNetwork.data(for: TestEndpoint())

        XCTAssertEqual(response, expectedResponse)
    }

    func testMockSessionNetworkCapturesRequestDetails() async throws {
        let mockSessionNetwork = MockSessionNetwork { _ in
            TestResponse(value: "ok")
        }

        _ = try await mockSessionNetwork.data(for: TestEndpoint()) as TestResponse

        let capturedRequests = await mockSessionNetwork.capturedRequests
        XCTAssertEqual(
            capturedRequests,
            [NetworkRequestCapture(url: "https://example.com/air-quality", method: .get)]
        )
    }

    func testMockSessionNetworkStoresLastEndpoint() async throws {
        let mockSessionNetwork = MockSessionNetwork { _ in
            TestResponse(value: "ok")
        }

        _ = try await mockSessionNetwork.data(for: TestEndpoint()) as TestResponse

        let endpoint = await mockSessionNetwork.endpoint
        XCTAssertEqual(endpoint?.url, "https://example.com/air-quality")
        XCTAssertEqual(endpoint?.method, .get)
    }

    func testMockSessionNetworkThrowsExplicitError() async {
        let mockSessionNetwork = MockSessionNetwork(error: NetworkError.generic(TestError.test))

        do {
            _ = try await mockSessionNetwork.data(for: TestEndpoint()) as TestResponse
            XCTFail("Expected explicit mock error")
        } catch {
            XCTAssertEqual(error, NetworkError.generic(TestError.test))
        }
    }

    func testMockSessionNetworkThrowsMissingStubbedResponse() async {
        let mockSessionNetwork = MockSessionNetwork()

        do {
            _ = try await mockSessionNetwork.data(for: TestEndpoint()) as TestResponse
            XCTFail("Expected missing stubbed response error")
        } catch {
            XCTAssertEqual(error, .missingStubbedResponse)
        }
    }

    func testMockSessionNetworkThrowsWhenStubTypeDoesNotMatchEndpointResponse() async {
        let mockSessionNetwork = MockSessionNetwork { _ in
            WrongResponse(value: 1)
        }

        do {
            _ = try await mockSessionNetwork.data(for: TestEndpoint()) as TestResponse
            XCTFail("Expected response type mismatch error")
        } catch {
            XCTAssertEqual(error, .responseTypeMismatch)
        }
    }

    func testNetworkingFetchReturnsStubbedResponse() async throws {
        let expectedResponse = TestResponse(value: "ok")
        let networking = Networking(
            sessionNetwork: MockSessionNetwork { _ in
                expectedResponse
            }
        )

        let response = try await networking.fetch(TestEndpoint())

        XCTAssertEqual(response, expectedResponse)
    }

    func testNetworkingMockFactoryReturnsStubbedResponse() async throws {
        let networking = Networking.mock { _ in
            TestResponse(value: "ok")
        }

        let response = try await networking.fetch(TestEndpoint())

        XCTAssertEqual(response, TestResponse(value: "ok"))
    }

    func testNetworkingMockFactoryPropagatesError() async {
        let networking = Networking.mock(error: NetworkError.generic(TestError.test))

        do {
            _ = try await networking.fetch(TestEndpoint()) as TestResponse
            XCTFail("Expected mock error")
        } catch {
            XCTAssertEqual(error, NetworkError.generic(TestError.test))
        }
    }

    func testSessionNetworkDecodesSuccessResponse() async throws {
        let sessionNetwork = SessionNetwork(session: makeStubSession())
        let expectedResponse = TestResponse(value: "ok")

        StubURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.absoluteString, "https://example.com/air-quality")
            return (
                HTTPURLResponse(
                    url: try XCTUnwrap(request.url),
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!,
                try JSONEncoder().encode(expectedResponse)
            )
        }

        let response = try await sessionNetwork.data(for: TestEndpoint())

        XCTAssertEqual(response, expectedResponse)
    }

    func testSessionNetworkThrowsDecodedFailureResponse() async {
        let sessionNetwork = SessionNetwork(session: makeStubSession())
        let expectedFailure = TestFailureResponse(message: "Invalid API key")

        StubURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 401,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )!,
                try JSONEncoder().encode(expectedFailure)
            )
        }

        do {
            _ = try await sessionNetwork.data(for: TestEndpoint()) as TestResponse
            XCTFail("Expected decoded failure response")
        } catch {
            XCTAssertEqual(
                error,
                .failureResponse(statusCode: 401, response: expectedFailure)
            )
        }
    }
}

private struct TestEndpoint: ServiceEndpoint {
    typealias Body = EmptyBody
    typealias SuccessResponse = TestResponse
    typealias FailureResponse = TestFailureResponse

    let body: EmptyBody? = nil
    let method: RequestMethod = .get
    let baseURL = "https://example.com"
    let path = "/air-quality"
}

private struct EmptyBody: Encodable, Sendable {}

private struct TestResponse: Codable, Equatable, Sendable {
    let value: String
}

private enum TestError: Error, Equatable {
    case test
}

private struct TestFailureResponse: Codable, Equatable, Sendable {
    let message: String
}

private struct WrongResponse: Decodable, Sendable {
    let value: Int
}

private final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NetworkError.generic(TestError.test))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private func makeStubSession() -> Session {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [StubURLProtocol.self]
    return Session(configuration: configuration)
}
