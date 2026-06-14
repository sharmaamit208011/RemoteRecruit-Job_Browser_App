//
//  OpeningsListViewModelTests.swift
//  OpeningsListViewModelTests
//
//  Created by Amit Sharma on 14/06/26.
//

import Testing
@testable import RemoteRecruit
import RRNetworking

@MainActor
@Suite("Openings list view model")
struct OpeningsListViewModelTests {
    @Test("starts in idle state")
    func initialStateIsIdle() {
        let sut = OpeningsListViewModel(openingProvider: StubJobOpeningProvider())

        if case .idle = sut.state {
            #expect(sut.state.isLoading == false)
            #expect(sut.state.value == nil)
            #expect(sut.state.errorMessage == nil)
        } else {
            Issue.record("Expected idle state on init")
        }
    }

    @Test("loadOpenings sets loading and then loaded state")
    func loadOpeningsSetsLoadedState() async {
        let service = StubJobOpeningProvider(stubbedOpenings: JobOpening.testMocks)
        let sut = OpeningsListViewModel(openingProvider: service)

        await sut.loadOpenings()

        #expect(service.requestCount == 1)
        #expect(sut.visibleOpenings == JobOpening.testMocks)
        #expect(sut.state.value?.count == JobOpening.testMocks.count)
    }

    @Test("loadOpenings sets empty state when the service returns no openings")
    func loadOpeningsSetsEmptyStateWhenNoOpenings() async {
        let sut = OpeningsListViewModel(openingProvider: StubJobOpeningProvider(stubbedOpenings: []))

        await sut.loadOpenings()

        if case .empty = sut.state {
            #expect(sut.visibleOpenings.isEmpty)
        } else {
            Issue.record("Expected empty state")
        }
    }

    @Test("loadOpenings sets error state on failure")
    func loadOpeningsSetsErrorStateOnFailure() async {
        let service = StubJobOpeningProvider(stubbedOpenings: JobOpening.testMocks, errorToThrow: NetworkError.timeout)
        let sut = OpeningsListViewModel(openingProvider: service)

        await sut.loadOpenings()

        #expect(sut.state.errorMessage?.isEmpty == false)
        if case .error = sut.state {
            #expect(sut.visibleOpenings.isEmpty)
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test(
        "search filters by supported fields",
        arguments: [
            ("iOS", ["1"]),
            ("acme", ["1"]),
            ("london", ["3"]),
            ("Back-end", ["3"])
        ]
    )
    func searchFiltersBySupportedFields(query: String, expectedIDs: [String]) async {
        let sut = OpeningsListViewModel(openingProvider: StubJobOpeningProvider(stubbedOpenings: JobOpening.testMocks))

        await sut.loadOpenings()
        sut.search(query: query)

        #expect(sut.visibleOpenings.map(\.id) == expectedIDs)
        #expect(sut.searchText == query)
        #expect(sut.state.value?.map(\.id) == expectedIDs)
    }

    @Test("blank search restores all openings after trimming whitespace")
    func blankSearchRestoresAllOpenings() async {
        let sut = OpeningsListViewModel(openingProvider: StubJobOpeningProvider(stubbedOpenings: JobOpening.testMocks))

        await sut.loadOpenings()
        sut.search(query: "iOS")
        sut.search(query: "   ")

        #expect(sut.visibleOpenings == JobOpening.testMocks)
        #expect(sut.state.value == JobOpening.testMocks)
    }

    @Test("search with no match sets empty state")
    func searchWithNoMatchSetsEmptyState() async {
        let sut = OpeningsListViewModel(openingProvider: StubJobOpeningProvider(stubbedOpenings: JobOpening.testMocks))

        await sut.loadOpenings()
        sut.search(query: "zzznomatch999")

        #expect(sut.visibleOpenings.isEmpty)
        if case .empty = sut.state {
            #expect(true)
        } else {
            Issue.record("Expected empty state for no-match search")
        }
    }
}

private final class StubJobOpeningProvider: JobOpeningProvider {
    var stubbedOpenings: [JobOpening]
    var errorToThrow: Error?
    var requestCount = 0

    init(stubbedOpenings: [JobOpening] = [], errorToThrow: Error? = nil) {
        self.stubbedOpenings = stubbedOpenings
        self.errorToThrow = errorToThrow
    }

    func fetchOpenings() async throws -> [JobOpening] {
        requestCount += 1
        if let errorToThrow {
            throw errorToThrow
        }
        return stubbedOpenings
    }
}

extension JobOpening {
    static var testMocks: [JobOpening] {
        [
            JobOpening(id: "1", title: "iOS Engineer", description: "Build apps.", company: "Acme Corp",
                location: "Remote", salaryFrom: 120000, salaryTo: 160000,
                employmentType: "Full-time Developer", applicationDeadline: "Mon, 12/31/2025",
                qualifications: "[\"Swift\"]", contact: "hr@acme.com",
                category: "Mobile App Developer", remoteWorkFlag: 1, openingsCount: 1,
                createdAt: "Sun, 10/15/2023", updatedAt: "Sun, 10/15/2023"),
            JobOpening(id: "2", title: "Android Engineer", description: "Build Android apps.", company: "Beta Ltd",
                location: "New York", salaryFrom: 100000, salaryTo: 140000,
                employmentType: "Contract Developer", applicationDeadline: "Fri, 06/30/2025",
                qualifications: "[\"Kotlin\"]", contact: "hr@beta.com",
                category: "Mobile App Developer", remoteWorkFlag: 0, openingsCount: 2,
                createdAt: "Sun, 10/15/2023", updatedAt: "Sun, 10/15/2023"),
            JobOpening(id: "3", title: "Backend Engineer", description: "Build APIs.", company: "Gamma Inc",
                location: "London", salaryFrom: 90000, salaryTo: 130000,
                employmentType: "Freelance Developer", applicationDeadline: "Wed, 03/15/2025",
                qualifications: "[\"Go\",\"Kubernetes\"]", contact: "hr@gamma.com",
                category: "Back-end Developer", remoteWorkFlag: 1, openingsCount: 4,
                createdAt: "Sun, 10/15/2023", updatedAt: "Sun, 10/15/2023")
        ]
    }
}
