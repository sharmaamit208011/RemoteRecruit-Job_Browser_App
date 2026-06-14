//
//  RemoteJobOpeningProviderTests.swift
//  RemoteJobOpeningProviderTests
//
//  Created by Amit Sharma on 14/06/26.
//

import Testing
@testable import RRNetworking

@Suite("Job opening provider")
struct RemoteJobOpeningProviderTests {
    @Test("bundled provider loads fallback openings without touching the network")
    func bundledProviderLoadsFallbackOpenings() async throws {
        let provider = BundledJobOpeningProvider()

        let openings = try await provider.fetchOpenings()

        #expect(openings.isEmpty == false)
    }

    @Test("fetchOpenings returns network openings when the request succeeds")
    func fetchOpeningsSuccess() async throws {
        let openings = [JobOpening.mock(id: "test-001"), JobOpening.mock(id: "test-002")]
        let mockClient = MockHTTPClient(stubbedResult: .success(openings))
        let sut = RemoteJobOpeningProvider(client: mockClient)

        let result = try await sut.fetchOpenings()

        #expect(result == openings)
        #expect(mockClient.requestCallCount == 1)
        #expect(mockClient.lastEndpoint?.path == "/jobs")
        #expect(mockClient.lastEndpoint?.method == .get)
    }

    @Test(
        "fetchOpenings falls back to bundled data when network fails",
        arguments: [
            NetworkError.noConnection,
            NetworkError.serverError(500),
            NetworkError.timeout
        ]
    )
    func fetchOpeningsFallsBackToLocal(error: NetworkError) async throws {
        let mockClient = MockHTTPClient(stubbedResult: .failure(error))
        let sut = RemoteJobOpeningProvider(client: mockClient)

        let result = try await sut.fetchOpenings()

        #expect(result.isEmpty == false)
        #expect(mockClient.requestCallCount == 1)
        #expect(mockClient.lastEndpoint?.path == "/jobs")
    }
}
