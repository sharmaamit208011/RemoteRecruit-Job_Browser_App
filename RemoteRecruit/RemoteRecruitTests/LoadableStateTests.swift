//
//  LoadableStateTests.swift
//  LoadableStateTests
//
//  Created by Amit Sharma on 14/06/26.
//

import Testing
@testable import RemoteRecruit

@Suite("View state")
struct LoadableStateTests {
    @Test("loading reports loading and no value")
    func loadingState() {
        let sut = LoadableState<[String]>.loading

        #expect(sut.isLoading)
        #expect(sut.value == nil)
        #expect(sut.errorMessage == nil)
    }

    @Test("loaded exposes its value")
    func loadedState() {
        let sut = LoadableState.loaded(["Swift", "Testing"])

        #expect(sut.isLoading == false)
        #expect(sut.value == ["Swift", "Testing"])
        #expect(sut.errorMessage == nil)
    }

    @Test("error exposes its message")
    func errorState() {
        let sut = LoadableState<Int>.error("Network failed")

        #expect(sut.isLoading == false)
        #expect(sut.value == nil)
        #expect(sut.errorMessage == "Network failed")
    }

    @Test("idle and empty have no value")
    func idleAndEmptyStates() {
        let idle = LoadableState<String>.idle
        let empty = LoadableState<String>.empty

        #expect(idle.isLoading == false)
        #expect(idle.value == nil)
        #expect(idle.errorMessage == nil)
        #expect(empty.isLoading == false)
        #expect(empty.value == nil)
        #expect(empty.errorMessage == nil)
    }
}
