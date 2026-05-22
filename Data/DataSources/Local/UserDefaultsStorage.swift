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
        static let flaggedCustomFieldId = "flaggedCustomFieldId"
        static let jiraEmail = "jiraEmail"
    }

    // MARK: - Jira Base URL

    func getJiraBaseURL() -> String {
        defaults.string(forKey: Keys.jiraBaseURL) ?? "https://lbc-lbc.atlassian.net"
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

    // MARK: - Jira Email

    func getJiraEmail() -> String {
        defaults.string(forKey: Keys.jiraEmail) ?? ""
    }

    func setJiraEmail(_ email: String) {
        defaults.set(email, forKey: Keys.jiraEmail)
    }

    // MARK: - Flagged Custom Field ID

    func getFlaggedCustomFieldId() -> String {
        defaults.string(forKey: Keys.flaggedCustomFieldId) ?? "customfield_10021"
    }

    func setFlaggedCustomFieldId(_ fieldId: String) {
        defaults.set(fieldId, forKey: Keys.flaggedCustomFieldId)
    }
}
