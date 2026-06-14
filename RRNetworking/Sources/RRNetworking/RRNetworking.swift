//
//  RRNetworking.swift
//  RRNetworking
//
//  Created by Amit Sharma on 14/06/26.
//

@_exported import Foundation

public enum RRNetworking {
    public static func makeDefaultOpeningProvider() -> JobOpeningProvider {
        makeRemoteOpeningProvider()
    }

    public static func makeRemoteOpeningProvider() -> JobOpeningProvider {
        let config = NetworkConfiguration.default
        let client = URLSessionHTTPClient(configuration: config)
        return RemoteJobOpeningProvider(client: client)
    }

    public static func makeOpeningProvider(
        baseURL: URL,
        timeoutInterval: TimeInterval = 30,
        retryCount: Int = 3,
        authToken: String? = nil
    ) -> JobOpeningProvider {
        let config = NetworkConfiguration(
            baseURL: baseURL,
            timeoutInterval: timeoutInterval,
            retryCount: retryCount
        )
        let client = URLSessionHTTPClient(configuration: config, authToken: authToken)
        return RemoteJobOpeningProvider(client: client)
    }
}
