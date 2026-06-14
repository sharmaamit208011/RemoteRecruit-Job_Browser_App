//
//  URLSessionHTTPClientTests.swift
//  URLSessionHTTPClientTests
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation
import Testing
@testable import RRNetworking

@Suite("URLSession HTTP client", .serialized)
struct URLSessionHTTPClientTests {
    @Test("request builds URLRequest and decodes successful response")
    func requestBuildsURLRequestAndDecodesResponse() async throws {
        let body = try #require("{\"name\":\"swift\"}".data(using: .utf8))
        let client = makeClient(authToken: "initial-token") { request in
            #expect(request.url?.absoluteString == "https://example.com/api/openings?q=ios")
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
            #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer initial-token")
            #expect(request.value(forHTTPHeaderField: "X-Test") == "yes")
            return .success(statusCode: 200, body: "{\"id\":42}")
        }

        let result: ResponseDTO = try await client.request(
            Endpoint(
                path: "/openings",
                method: .post,
                queryItems: [URLQueryItem(name: "q", value: "ios")],
                headers: ["X-Test": "yes"],
                body: body
            )
        )

        #expect(result.id == 42)
        #expect(MockURLProtocol.requestCount == 1)
    }

    @Test("request maps URL errors")
    func requestMapsURLErrors() async throws {
        let timeoutClient = makeClient { _ in
            .failure(URLError(.timedOut))
        }
        await #expect(throws: NetworkError.timeout) {
            let _: ResponseDTO = try await timeoutClient.request(Endpoint(path: "/openings"))
        }

        let offlineClient = makeClient { _ in
            .failure(URLError(.notConnectedToInternet))
        }
        await #expect(throws: NetworkError.noConnection) {
            let _: ResponseDTO = try await offlineClient.request(Endpoint(path: "/openings"))
        }

        let unknownClient = makeClient { _ in
            .failure(URLError(.badServerResponse))
        }
        await #expect(throws: NetworkError.unknown(URLError(.badServerResponse).localizedDescription)) {
            let _: ResponseDTO = try await unknownClient.request(Endpoint(path: "/openings"))
        }
    }

    @Test("request maps HTTP status and decoding failures")
    func requestMapsHTTPAndDecodingFailures() async throws {
        let unauthorizedClient = makeClient(retryCount: 0) { _ in
            .success(statusCode: 401, body: "{}")
        }
        await #expect(throws: NetworkError.unauthorized) {
            let _: ResponseDTO = try await unauthorizedClient.request(Endpoint(path: "/openings"))
        }

        let serverErrorClient = makeClient(retryCount: 0) { _ in
            .success(statusCode: 503, body: "{}")
        }
        await #expect(throws: NetworkError.serverError(503)) {
            let _: ResponseDTO = try await serverErrorClient.request(Endpoint(path: "/openings"))
        }

        let decodingClient = makeClient { _ in
            .success(statusCode: 200, body: "{\"unexpected\":true}")
        }
        await #expect(throws: (any Error).self) {
            let _: ResponseDTO = try await decodingClient.request(Endpoint(path: "/openings"))
        }
    }

    @Test("request retries transient failures")
    func requestRetriesTransientFailures() async throws {
        let client = makeClient(retryCount: 1) { _ in
            if MockURLProtocol.requestCount == 1 {
                return .failure(URLError(.networkConnectionLost))
            }
            return .success(statusCode: 200, body: "{\"id\":7}")
        }

        let result: ResponseDTO = try await client.request(Endpoint(path: "/openings"))

        #expect(result.id == 7)
        #expect(MockURLProtocol.requestCount == 2)
    }

    @Test("request refreshes auth after unauthorized response")
    func requestRefreshesAuthAfterUnauthorizedResponse() async throws {
        let client = makeClient(authToken: "expired", retryCount: 0) { request in
            if MockURLProtocol.requestCount == 1 {
                #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer expired")
                return .success(statusCode: 401, body: "{}")
            }
            #expect(request.value(forHTTPHeaderField: "Authorization")?.hasPrefix("Bearer refreshed-token-") == true)
            return .success(statusCode: 200, body: "{\"id\":9}")
        }

        let result: ResponseDTO = try await client.request(Endpoint(path: "/openings"))

        #expect(result.id == 9)
        #expect(MockURLProtocol.requestCount == 2)
    }

    private func makeClient(
        authToken: String? = nil,
        retryCount: Int = 0,
        handler: @escaping @Sendable (URLRequest) -> MockURLProtocol.MockResult
    ) -> URLSessionHTTPClient {
        MockURLProtocol.handler = handler
        MockURLProtocol.requestCount = 0

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [MockURLProtocol.self]

        return URLSessionHTTPClient(
            configuration: NetworkConfiguration(
                baseURL: URL(string: "https://example.com/api")!,
                timeoutInterval: 1,
                retryCount: retryCount,
                retryDelay: 0
            ),
            authToken: authToken,
            sessionConfiguration: sessionConfiguration
        )
    }
}

@Suite("RRNetworking factory")
struct RRNetworkingFactoryTests {
    @Test("factory methods return opening providers")
    func factoryMethodsReturnOpeningProviders() throws {
        let baseURL = try #require(URL(string: "https://example.com"))

        #expect(RRNetworking.makeDefaultOpeningProvider() is RemoteJobOpeningProvider)
        #expect(RRNetworking.makeRemoteOpeningProvider() is RemoteJobOpeningProvider)
        #expect(RRNetworking.makeOpeningProvider(baseURL: baseURL, timeoutInterval: 5, retryCount: 1, authToken: "token") is RemoteJobOpeningProvider)
    }
}

private struct ResponseDTO: Decodable, Equatable {
    let id: Int
}

private final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    enum MockResult: Sendable {
        case success(statusCode: Int, body: String)
        case failure(URLError)
    }

    static var handler: (@Sendable (URLRequest) -> MockResult)?
    static var requestCount = 0

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.requestCount += 1

        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: NetworkError.noData)
            return
        }

        switch handler(request) {
        case .success(let statusCode, let body):
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = Data(body.utf8)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        case .failure(let error):
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
