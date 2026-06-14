//
//  URLSessionHTTPClient.swift
//  RRNetworking
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession
    private let configuration: NetworkConfiguration
    private var authToken: String?

    public init(
        configuration: NetworkConfiguration = .default,
        authToken: String? = nil,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.configuration = configuration
        self.authToken = authToken

        let sessionConfig = sessionConfiguration
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.timeoutIntervalForResource = configuration.timeoutInterval * 2
        self.session = URLSession(configuration: sessionConfig)
    }

    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try await performWithRetry(endpoint: endpoint, attempt: 0)
    }

    private func performWithRetry<T: Decodable>(endpoint: Endpoint, attempt: Int) async throws -> T {
        do {
            return try await perform(endpoint: endpoint)
        } catch NetworkError.unauthorized {
            log("401 received. Refreshing auth token and retrying \(endpoint.method.rawValue) \(endpoint.path)")
            try await refreshAuth()
            return try await perform(endpoint: endpoint)
        } catch let error as NetworkError where error == .timeout || error == .noConnection {
            if attempt < configuration.retryCount {
                log("Retry \(attempt + 1)/\(configuration.retryCount) for \(endpoint.method.rawValue) \(endpoint.path) after \(error)")
                try await Task.sleep(nanoseconds: UInt64(configuration.retryDelay * 1_000_000_000))
                return try await performWithRetry(endpoint: endpoint, attempt: attempt + 1)
            }
            throw error
        } catch {
            if attempt < configuration.retryCount {
                log("Retry \(attempt + 1)/\(configuration.retryCount) for \(endpoint.method.rawValue) \(endpoint.path) after \(error)")
                try await Task.sleep(nanoseconds: UInt64(configuration.retryDelay * 1_000_000_000))
                return try await performWithRetry(endpoint: endpoint, attempt: attempt + 1)
            }
            throw error
        }
    }

    private func perform<T: Decodable>(endpoint: Endpoint) async throws -> T {
        var components = URLComponents(url: configuration.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        endpoint.headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        logRequest(request)

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            log("Transport error for \(endpoint.method.rawValue) \(url.absoluteString): \(urlError.localizedDescription)")
            switch urlError.code {
            case .timedOut:
                throw NetworkError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noConnection
            default:
                throw NetworkError.unknown(urlError.localizedDescription)
            }
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            log("Invalid response type for \(endpoint.method.rawValue) \(url.absoluteString)")
            throw NetworkError.unknown("Invalid response type")
        }
        logResponse(httpResponse, data: data)

        switch httpResponse.statusCode {
        case 200...299:
            break
        case 400:
            throw NetworkError.unauthorized
        case 401, 403:
            throw NetworkError.unauthorized
        default:
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            log("Decoding failed for \(endpoint.method.rawValue) \(url.absoluteString): \(error.localizedDescription)")
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    private func refreshAuth() async throws {
        try await Task.sleep(nanoseconds: 500_000_000)
        authToken = "refreshed-token-\(UUID().uuidString)"
        log("Auth token refreshed")
    }

    private func logRequest(_ request: URLRequest) {
        #if DEBUG
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "<invalid-url>"
        var headers = request.allHTTPHeaderFields ?? [:]
        if headers["Authorization"] != nil {
            headers["Authorization"] = "<redacted>"
        }
        let bodySize = request.httpBody?.count ?? 0
        log("REQUEST \(method) \(url) headers=\(headers) bodyBytes=\(bodySize)")
        #endif
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data) {
        #if DEBUG
        let url = response.url?.absoluteString ?? "<unknown-url>"
        log("RESPONSE \(response.statusCode) \(url) bytes=\(data.count)")
        #endif
    }

    private func log(_ message: String) {
        #if DEBUG
        print("[RRNetworking] \(message)")
        #endif
    }
}
