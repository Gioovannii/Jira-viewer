//
//  SimpleSecureStorage.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Simple storage using UserDefaults with basic obfuscation
/// NOTE: This is for development convenience. For production, use proper Keychain.
final class SimpleSecureStorage: SecureStorageProtocol {
    private let defaults = UserDefaults.standard
    private let prefix = "secure_"

    func save(_ value: String, forKey key: String) throws {
        // Basic obfuscation (NOT real encryption, just to avoid plain text)
        let obfuscated = obfuscate(value)
        defaults.set(obfuscated, forKey: prefix + key)
    }

    func retrieve(forKey key: String) throws -> String? {
        guard let obfuscated = defaults.string(forKey: prefix + key) else {
            return nil
        }
        return deobfuscate(obfuscated)
    }

    func delete(forKey key: String) throws {
        defaults.removeObject(forKey: prefix + key)
    }

    func contains(key: String) -> Bool {
        return defaults.object(forKey: prefix + key) != nil
    }

    // MARK: - Basic Obfuscation

    private func obfuscate(_ string: String) -> String {
        // Simple XOR with a key (NOT secure, just obfuscation)
        let key: UInt8 = 0x42
        let data = Data(string.utf8)
        let obfuscated = data.map { $0 ^ key }
        return Data(obfuscated).base64EncodedString()
    }

    private func deobfuscate(_ string: String) -> String? {
        let key: UInt8 = 0x42
        guard let data = Data(base64Encoded: string) else { return nil }
        let deobfuscated = data.map { $0 ^ key }
        return String(data: Data(deobfuscated), encoding: .utf8)
    }
}
