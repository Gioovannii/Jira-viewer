//
//  Issue.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira ticket (pure domain entity with business logic)
struct Issue: Identifiable, Hashable {
    let id: String
    let key: String
    let summary: String
    let description: String?
    let status: IssueStatus
    let assignee: User?
    let priority: IssuePriority?
    let issueType: IssueType
    let created: Date?
    let updated: Date?
    let resolved: Date?
    let sprint: Sprint?
    let timeTracking: TimeTracking?

    init(
        id: String,
        key: String,
        summary: String,
        description: String? = nil,
        status: IssueStatus,
        assignee: User? = nil,
        priority: IssuePriority? = nil,
        issueType: IssueType,
        created: Date? = nil,
        updated: Date? = nil,
        resolved: Date? = nil,
        sprint: Sprint? = nil,
        timeTracking: TimeTracking? = nil
    ) {
        self.id = id
        self.key = key
        self.summary = summary
        self.description = description
        self.status = status
        self.assignee = assignee
        self.priority = priority
        self.issueType = issueType
        self.created = created
        self.updated = updated
        self.resolved = resolved
        self.sprint = sprint
        self.timeTracking = timeTracking
    }

    // MARK: - Business Logic (Computed Properties)

    /// Is the ticket completed?
    var isCompleted: Bool {
        let statusName = status.name.lowercased()
        return statusName.contains("done") ||
               statusName.contains("terminé") ||
               statusName.contains("closed")
    }

    /// Is the ticket in progress?
    var isInProgress: Bool {
        let statusName = status.name.lowercased()
        return statusName.contains("progress") ||
               statusName.contains("cours")
    }

    /// Is the ticket to do?
    var isTodo: Bool {
        !isCompleted && !isInProgress
    }

    /// Cycle time in days (from creation to resolution)
    var cycleTimeDays: Double? {
        guard let created = created, let resolved = resolved else {
            return nil
        }
        let seconds = resolved.timeIntervalSince(created)
        return seconds / 86400.0 // 86400 seconds per day
    }

    /// Formatted cycle time
    var cycleTimeFormatted: String? {
        guard let days = cycleTimeDays else { return nil }
        return String(format: "%.1f days", days)
    }

    /// Is the priority high?
    var isHighPriority: Bool {
        guard let priorityName = priority?.name.lowercased() else {
            return false
        }
        return priorityName.contains("high") || priorityName.contains("highest")
    }

    /// Assignee name or "Unassigned"
    var assigneeName: String {
        assignee?.displayName ?? "Unassigned"
    }
}
