//
//  SettingsViewModel.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

/// ViewModel for settings (MVVM pattern)
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var jiraBaseURL: String = ""
    @Published var jiraToken: String = ""
    @Published var projectKey: String = ""
    @Published var flaggedFieldId: String = ""
    @Published var errorMessage: String?
    @Published var successMessage: String?

    // MARK: - Dependencies

    private let configRepository: ConfigRepositoryProtocol

    // MARK: - Initialization

    init(configRepository: ConfigRepositoryProtocol) {
        self.configRepository = configRepository
        loadConfiguration()
    }

    // MARK: - Computed Properties

    /// Is the token configured?
    var isTokenConfigured: Bool {
        !jiraToken.isEmpty
    }

    /// Is the configuration valid?
    var isConfigurationValid: Bool {
        !jiraBaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !jiraToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !projectKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Public Methods

    /// Loads the configuration from the repository
    func loadConfiguration() {
        jiraBaseURL = configRepository.getJiraBaseURL()
        jiraToken = configRepository.getJiraToken() ?? ""
        projectKey = configRepository.getProjectKey()
        flaggedFieldId = configRepository.getFlaggedCustomFieldId()
    }

    /// Saves the configuration
    func saveConfiguration() {
        errorMessage = nil
        successMessage = nil

        // Validation
        guard isConfigurationValid else {
            errorMessage = "All fields are required"
            return
        }

        // Save
        configRepository.setJiraBaseURL(jiraBaseURL)
        configRepository.setProjectKey(projectKey)

        // Save the token in the Keychain
        do {
            try configRepository.setJiraToken(jiraToken)
            successMessage = "Configuration saved successfully"
        } catch {
            errorMessage = "Failed to save token: \(error.localizedDescription)"
        }
    }

    /// Deletes the token
    func deleteToken() {
        do {
            try configRepository.deleteJiraToken()
            jiraToken = ""
            successMessage = "Token deleted"
        } catch {
            errorMessage = "Failed to delete token: \(error.localizedDescription)"
        }
    }

    /// Saves the flagged field ID
    func saveFlaggedFieldId() {
        configRepository.setFlaggedCustomFieldId(flaggedFieldId)
    }

    /// Clears the messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
