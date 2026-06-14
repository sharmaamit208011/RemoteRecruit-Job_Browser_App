//
//  NetworkErrorTests.swift
//  NetworkErrorTests
//
//  Created by Amit Sharma on 14/06/26.
//

import Testing
@testable import RRNetworking

@Suite("Network error")
struct NetworkErrorTests {
    @Test(
        "all errors provide a description",
        arguments: [
            NetworkError.invalidURL,
            NetworkError.noData,
            NetworkError.unauthorized,
            NetworkError.timeout,
            NetworkError.noConnection,
            NetworkError.serverError(500),
            NetworkError.decodingFailed("bad json"),
            NetworkError.unknown("mystery")
        ]
    )
    func errorDescriptions(error: NetworkError) {
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test("error equality compares associated values")
    func errorEquality() {
        #expect(NetworkError.invalidURL == .invalidURL)
        #expect(NetworkError.noData == .noData)
        #expect(NetworkError.unauthorized == .unauthorized)
        #expect(NetworkError.timeout == .timeout)
        #expect(NetworkError.noConnection == .noConnection)
        #expect(NetworkError.serverError(404) == .serverError(404))
        #expect(NetworkError.serverError(404) != .serverError(500))
        #expect(NetworkError.decodingFailed("msg") == .decodingFailed("msg"))
        #expect(NetworkError.decodingFailed("a") != .decodingFailed("b"))
        #expect(NetworkError.unknown("a") == .unknown("a"))
        #expect(NetworkError.unknown("a") != .unknown("b"))
        #expect(NetworkError.timeout != .noConnection)
    }

    @Test("server error description contains the status code")
    func serverErrorContainsCode() {
        #expect(NetworkError.serverError(503).errorDescription?.contains("503") == true)
    }
}
