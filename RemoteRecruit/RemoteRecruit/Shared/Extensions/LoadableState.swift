//
//  LoadableState.swift
//  RemoteRecruit
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation

enum LoadableState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var value: T? {
        if case .loaded(let value) = self { return value }
        return nil
    }

    var errorMessage: String? {
        if case .error(let msg) = self { return msg }
        return nil
    }
}
