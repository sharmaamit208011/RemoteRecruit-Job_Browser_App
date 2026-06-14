//
//  HTTPClient.swift
//  RRNetworking
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation

public protocol HTTPClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]?
    public let headers: [String: String]?
    public let body: Data?

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
