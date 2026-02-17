//
//  IssueDetailViewModel.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AppKit

/// ViewModel for issue detail (MVVM pattern)
@MainActor
final class IssueDetailViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var issue: Issue

    // MARK: - Dependencies

    private let configRepository: ConfigRepositoryProtocol

    // MARK: - Initialization

    init(
        issue: Issue,
        configRepository: ConfigRepositoryProtocol
    ) {
        self.issue = issue
        self.configRepository = configRepository
    }

    // MARK: - Computed Properties

    /// URL to open the issue in Jira
    var jiraURL: URL? {
        let baseURL = configRepository.getJiraBaseURL()
        return URL(string: "\(baseURL)/browse/\(issue.key)")
    }

    /// Formatted created date text
    var createdDateFormatted: String? {
        guard let date = issue.created else { return nil }
        return DateFormatter.formatForDisplay(date)
    }

    /// Formatted updated date text
    var updatedDateFormatted: String? {
        guard let date = issue.updated else { return nil }
        return DateFormatter.formatForDisplay(date)
    }

    /// Formatted resolved date text
    var resolvedDateFormatted: String? {
        guard let date = issue.resolved else { return nil }
        return DateFormatter.formatForDisplay(date)
    }

    // MARK: - Actions

    /// Opens the issue in Jira browser
    func openInJira() {
        guard let url = jiraURL else { return }
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}
