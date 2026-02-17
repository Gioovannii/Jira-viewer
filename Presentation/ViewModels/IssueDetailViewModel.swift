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

    /// Status history formatted for timeline display
    var statusHistory: [(status: String, duration: String, date: String)] {
        guard let history = issue.history else { return [] }

        let transitions = history.transitions.sorted { $0.transitionDate < $1.transitionDate }
        var result: [(status: String, duration: String, date: String)] = []

        for (index, transition) in transitions.enumerated() {
            let nextTransition = index + 1 < transitions.count ? transitions[index + 1] : nil
            let duration: TimeInterval

            if let next = nextTransition {
                duration = next.transitionDate.timeIntervalSince(transition.transitionDate)
            } else {
                // Current status (still ongoing)
                duration = Date().timeIntervalSince(transition.transitionDate)
            }

            let durationDays = duration / 86400.0
            let durationFormatted = String(format: "%.1f days", durationDays)
            let dateFormatted = DateFormatter.formatForDisplay(transition.transitionDate) ?? ""

            result.append((
                status: transition.toStatus,
                duration: durationFormatted,
                date: dateFormatted
            ))
        }

        return result
    }

    /// Blockage information string
    var blockageInfo: String? {
        guard issue.isBlocked else { return nil }

        if issue.isFlagged {
            if let days = issue.daysInCurrentStatus {
                return "Flagged as blocked for \(String(format: "%.1f", days)) days"
            }
            return "Flagged as blocked"
        } else if let days = issue.daysInCurrentStatus {
            return "Stagnant for \(String(format: "%.1f", days)) days"
        }

        return "Blocked"
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
