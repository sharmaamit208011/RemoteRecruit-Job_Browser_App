//
//  NetworkingModelTests.swift
//  NetworkingModelTests
//
//  Created by Amit Sharma on 14/06/26.
//


import Foundation
import Testing
@testable import RRNetworking

@Suite("Networking support models")
struct NetworkingModelTests {
    @Test("endpoint defaults to a GET request with no optional request parts")
    func endpointDefaults() {
        let sut = Endpoint(path: "/openings")

        #expect(sut.path == "/openings")
        #expect(sut.method == .get)
        #expect(sut.queryItems == nil)
        #expect(sut.headers == nil)
        #expect(sut.body == nil)
    }

    @Test("endpoint stores custom request parts")
    func endpointCustomValues() throws {
        let body = try #require("{}".data(using: .utf8))
        let sut = Endpoint(
            path: "/openings/search",
            method: .post,
            queryItems: [URLQueryItem(name: "q", value: "ios")],
            headers: ["Authorization": "Bearer token"],
            body: body
        )

        #expect(sut.path == "/openings/search")
        #expect(sut.method == .post)
        #expect(sut.queryItems?.first?.name == "q")
        #expect(sut.queryItems?.first?.value == "ios")
        #expect(sut.headers?["Authorization"] == "Bearer token")
        #expect(sut.body == body)
    }

    @Test("HTTP methods expose API raw values")
    func httpMethodRawValues() {
        #expect(HTTPMethod.get.rawValue == "GET")
        #expect(HTTPMethod.post.rawValue == "POST")
        #expect(HTTPMethod.put.rawValue == "PUT")
        #expect(HTTPMethod.delete.rawValue == "DELETE")
    }

    @Test("network configuration stores custom values")
    func networkConfigurationCustomValues() throws {
        let url = try #require(URL(string: "https://example.com"))
        let sut = NetworkConfiguration(
            baseURL: url,
            timeoutInterval: 10,
            retryCount: 2,
            retryDelay: 0.5
        )

        #expect(sut.baseURL == url)
        #expect(sut.timeoutInterval == 10)
        #expect(sut.retryCount == 2)
        #expect(sut.retryDelay == 0.5)
    }

    @Test("default network configuration targets the openings API")
    func defaultNetworkConfiguration() {
        let sut = NetworkConfiguration.default

        #expect(sut.baseURL.absoluteString == "https://jsonfakery.com")
        #expect(sut.timeoutInterval == 30)
        #expect(sut.retryCount == 3)
        #expect(sut.retryDelay == 1.0)
    }
}
