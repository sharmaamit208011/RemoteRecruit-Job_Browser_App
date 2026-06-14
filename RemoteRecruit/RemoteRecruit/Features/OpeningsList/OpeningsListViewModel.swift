//
//  OpeningsListViewModel.swift
//  RemoteRecruit
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation
import RRNetworking

@MainActor
final class OpeningsListViewModel: ObservableObject {
    @Published var state: LoadableState<[JobOpening]> = .idle
    @Published var searchText: String = ""
    @Published var visibleOpenings: [JobOpening] = []

    private let openingProvider: JobOpeningProvider
    private var allOpenings: [JobOpening] = []

    init(openingProvider: JobOpeningProvider = RRNetworking.makeDefaultOpeningProvider()) {
        self.openingProvider = openingProvider
    }

    func loadOpenings() async {
        state = .loading
        do {
            let openings = try await openingProvider.fetchOpenings()
            allOpenings = openings
            if openings.isEmpty {
                state = .empty
            } else {
                state = .loaded(openings)
                visibleOpenings = openings
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func search(query: String) {
        searchText = query
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            visibleOpenings = allOpenings
        } else {
            let lowered = query.lowercased()
            visibleOpenings = allOpenings.filter {
                $0.title.lowercased().contains(lowered) ||
                $0.company.lowercased().contains(lowered) ||
                $0.location.lowercased().contains(lowered) ||
                $0.category.lowercased().contains(lowered)
            }
        }
        refreshStateAfterSearch()
    }

    private func refreshStateAfterSearch() {
        if visibleOpenings.isEmpty && !allOpenings.isEmpty {
            state = .empty
        } else if !visibleOpenings.isEmpty {
            state = .loaded(visibleOpenings)
        }
    }
}
