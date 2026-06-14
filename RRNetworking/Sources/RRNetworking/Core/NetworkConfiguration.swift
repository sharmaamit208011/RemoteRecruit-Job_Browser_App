//
//  NetworkConfiguration.swift
//  RRNetworking
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation

public struct NetworkConfiguration {
    public let baseURL: URL
    public let timeoutInterval: TimeInterval
    public let retryCount: Int
    public let retryDelay: TimeInterval

    public init(
        baseURL: URL,
        timeoutInterval: TimeInterval = 30,
        retryCount: Int = 3,
        retryDelay: TimeInterval = 1.0
    ) {
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
        self.retryCount = retryCount
        self.retryDelay = retryDelay
    }

    public static var `default`: NetworkConfiguration {
        NetworkConfiguration(
            baseURL: URL(string: "https://jsonfakery.com")!,
            timeoutInterval: 30,
            retryCount: 3,
            retryDelay: 1.0
        )
    }
}
