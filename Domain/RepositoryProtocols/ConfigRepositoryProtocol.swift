//
//  ConfigRepositoryProtocol.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Protocol for configuration repository (Dependency Inversion)
protocol ConfigRepositoryProtocol {
    /// Jira base URL
    func getJiraBaseURL() -> String
    func setJiraBaseURL(_ url: String)

    /// Email address for Basic Auth (Jira Cloud)
    func getJiraEmail() -> String
    func setJiraEmail(_ email: String)

    /// Authentication token (stored in Keychain)
    func getJiraToken() -> String?
    func setJiraToken(_ token: String) throws
    func deleteJiraToken() throws

    /// Project key
    func getProjectKey() -> String
    func setProjectKey(_ key: String)

    /// Flagged custom field ID
    func getFlaggedCustomFieldId() -> String
    func setFlaggedCustomFieldId(_ fieldId: String)

    /// Checks if the configuration is complete
    var isConfigured: Bool { get }
}
