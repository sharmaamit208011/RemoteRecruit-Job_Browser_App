//
//  JobOpeningProvider.swift
//  RRNetworking
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation

public protocol JobOpeningProvider {
    func fetchOpenings() async throws -> [JobOpening]
}

public final class BundledJobOpeningProvider: JobOpeningProvider {
    public init() {}

    public func fetchOpenings() async throws -> [JobOpening] {
        let openings = try Self.loadBundledOpenings()
        Self.log("Loaded \(openings.count) openings from bundled jobData.json")
        return openings
    }

    static func loadBundledOpenings() throws -> [JobOpening] {
        guard let url = Bundle.module.url(forResource: "jobData", withExtension: "json") else {
            log("Bundled jobData.json was not found")
            throw NetworkError.noData
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode([JobOpening].self, from: data)
    }

    private static func log(_ message: String) {
        #if DEBUG
        print("[RRNetworking] \(message)")
        #endif
    }
}

public final class RemoteJobOpeningProvider: JobOpeningProvider {
    private let client: HTTPClientProtocol

    public init(client: HTTPClientProtocol) {
        self.client = client
    }

    public func fetchOpenings() async throws -> [JobOpening] {
        do {
            log("Fetching openings from remote /jobs endpoint")
            return try await client.request(Endpoint(path: "/jobs"))
        } catch {
            log("Remote fetch failed. Falling back to bundled openings. error=\(error)")
            return try BundledJobOpeningProvider.loadBundledOpenings()
        }
    }

    private func log(_ message: String) {
        #if DEBUG
        print("[RRNetworking] \(message)")
        #endif
    }
}
