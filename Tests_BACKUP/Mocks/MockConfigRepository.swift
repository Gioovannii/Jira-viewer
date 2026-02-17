//
//  MockConfigRepository.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Mock of ConfigRepository for testing
final class MockConfigRepository: ConfigRepositoryProtocol {
    var jiraBaseURL: String = "https://jira.test.com"
    var jiraToken: String? = "test_token"
    var projectKey: String = "TEST"

    var setJiraTokenCalled = false
    var deleteJiraTokenCalled = false

    func getJiraBaseURL() -> String {
        return jiraBaseURL
    }

    func setJiraBaseURL(_ url: String) {
        jiraBaseURL = url
    }

    func getJiraToken() -> String? {
        return jiraToken
    }

    func setJiraToken(_ token: String) throws {
        setJiraTokenCalled = true
        jiraToken = token
    }

    func deleteJiraToken() throws {
        deleteJiraTokenCalled = true
        jiraToken = nil
    }

    func getProjectKey() -> String {
        return projectKey
    }

    func setProjectKey(_ key: String) {
        projectKey = key
    }

    var isConfigured: Bool {
        return !jiraBaseURL.isEmpty && jiraToken != nil && !jiraToken!.isEmpty && !projectKey.isEmpty
    }
}
