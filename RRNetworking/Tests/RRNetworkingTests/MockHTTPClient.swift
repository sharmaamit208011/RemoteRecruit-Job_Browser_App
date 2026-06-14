//
//  MockHTTPClient.swift
//  MockHTTPClient
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation
@testable import RRNetworking

final class MockHTTPClient: HTTPClientProtocol {
    var stubbedResult: Result<Any, Error>?
    var requestCallCount = 0
    var lastEndpoint: Endpoint?

    init(stubbedResult: Result<Any, Error>? = nil) {
        self.stubbedResult = stubbedResult
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        lastEndpoint = endpoint

        switch stubbedResult {
        case .success(let value):
            guard let typed = value as? T else {
                throw NetworkError.decodingFailed("Type mismatch in mock")
            }
            return typed
        case .failure(let error):
            throw error
        case nil:
            throw NetworkError.noData
        }
    }
}
