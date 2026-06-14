//
//  NetworkError.swift
//  RRNetworking
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation

public enum NetworkError: Error, LocalizedError, Equatable {
    case invalidURL
    case noData
    case decodingFailed(String)
    case serverError(Int)
    case unauthorized
    case timeout
    case noConnection
    case unknown(String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .noData:
            return "No data was returned from the server."
        case .decodingFailed(let msg):
            return "Failed to decode response: \(msg)"
        case .serverError(let code):
            return "Server returned an error (code \(code))."
        case .unauthorized:
            return "Authentication failed. Please try again."
        case .timeout:
            return "The request timed out. Please check your connection."
        case .noConnection:
            return "No internet connection."
        case .unknown(let msg):
            return msg
        }
    }

    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL): return true
        case (.noData, .noData): return true
        case (.unauthorized, .unauthorized): return true
        case (.timeout, .timeout): return true
        case (.noConnection, .noConnection): return true
        case (.serverError(let a), .serverError(let b)): return a == b
        case (.decodingFailed(let a), .decodingFailed(let b)): return a == b
        case (.unknown(let a), .unknown(let b)): return a == b
        default: return false
        }
    }
}
