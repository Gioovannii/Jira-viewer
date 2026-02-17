//
//  SecureStorage.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Protocol to abstract secure storage (allows mocking in tests)
protocol SecureStorageProtocol {
    func save(_ value: String, forKey key: String) throws
    func retrieve(forKey key: String) throws -> String?
    func delete(forKey key: String) throws
    func contains(key: String) -> Bool
}

/// Errors related to secure storage
enum SecureStorageError: LocalizedError {
    case saveFailed
    case retrievalFailed
    case deletionFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save to secure storage"
        case .retrievalFailed:
            return "Failed to retrieve from secure storage"
        case .deletionFailed:
            return "Failed to delete from secure storage"
        case .notFound:
            return "Key not found in secure storage"
        }
    }
}
