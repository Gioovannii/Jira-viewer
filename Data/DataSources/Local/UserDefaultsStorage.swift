//
//  UserDefaultsStorage.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Wrapper around UserDefaults to store non-sensitive configurations
final class UserDefaultsStorage {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Keys

    private enum Keys {
        static let jiraBaseURL = "jiraBaseURL"
        static let projectKey = "projectKey"
    }

    // MARK: - Jira Base URL

    func getJiraBaseURL() -> String {
        defaults.string(forKey: Keys.jiraBaseURL) ?? "https://jira.ets.mpi-internal.com"
    }

    func setJiraBaseURL(_ url: String) {
        defaults.set(url, forKey: Keys.jiraBaseURL)
    }

    // MARK: - Project Key

    func getProjectKey() -> String {
        defaults.string(forKey: Keys.projectKey) ?? "LBCMONSPE"
    }

    func setProjectKey(_ key: String) {
        defaults.set(key, forKey: Keys.projectKey)
    }
}
