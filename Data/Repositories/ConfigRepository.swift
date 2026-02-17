//
//  ConfigRepository.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Configuration repository implementation
final class ConfigRepository: ConfigRepositoryProtocol {
    private let secureStorage: SecureStorageProtocol
    private let userDefaultsStorage: UserDefaultsStorage

    // Key for the token in Keychain
    private let tokenKey = "jira_api_token"

    init(
        secureStorage: SecureStorageProtocol,
        userDefaultsStorage: UserDefaultsStorage
    ) {
        self.secureStorage = secureStorage
        self.userDefaultsStorage = userDefaultsStorage
    }

    // MARK: - Jira Base URL

    func getJiraBaseURL() -> String {
        userDefaultsStorage.getJiraBaseURL()
    }

    func setJiraBaseURL(_ url: String) {
        userDefaultsStorage.setJiraBaseURL(url)
    }

    // MARK: - Jira Token (Keychain)

    func getJiraToken() -> String? {
        try? secureStorage.retrieve(forKey: tokenKey)
    }

    func setJiraToken(_ token: String) throws {
        try secureStorage.save(token, forKey: tokenKey)
    }

    func deleteJiraToken() throws {
        try secureStorage.delete(forKey: tokenKey)
    }

    // MARK: - Project Key

    func getProjectKey() -> String {
        userDefaultsStorage.getProjectKey()
    }

    func setProjectKey(_ key: String) {
        userDefaultsStorage.setProjectKey(key)
    }

    // MARK: - Flagged Custom Field ID

    func getFlaggedCustomFieldId() -> String {
        userDefaultsStorage.getFlaggedCustomFieldId()
    }

    func setFlaggedCustomFieldId(_ fieldId: String) {
        userDefaultsStorage.setFlaggedCustomFieldId(fieldId)
    }

    // MARK: - Configuration Status

    var isConfigured: Bool {
        let hasToken = (getJiraToken()?.isEmpty == false)
        let hasURL = !getJiraBaseURL().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasProject = !getProjectKey().trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasToken && hasURL && hasProject
    }
}
