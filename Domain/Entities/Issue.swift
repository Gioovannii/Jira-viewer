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
    let history: IssueHistory?
    let isFlagged: Bool

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
        timeTracking: TimeTracking? = nil,
        history: IssueHistory? = nil,
        isFlagged: Bool = false
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
        self.history = history
        self.isFlagged = isFlagged
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

    // MARK: - Blocked Issue Detection

    /// Days in current status
    var daysInCurrentStatus: Double? {
        // Try to get duration from history first
        if let history = history, !history.transitions.isEmpty {
            if let duration = history.currentStatusDuration(currentStatus: status.name) {
                let days = duration / 86400.0
                print("📅 [DAYS] \(key): \(String(format: "%.1f", days))d in \(status.name) (from history)")
                return days
            }
        }

        // Fallback: Use updated date if history is unavailable or empty
        guard let updated = updated else {
            print("⚠️ [DAYS] \(key): No updated date, can't calculate days")
            return nil
        }
        let daysSinceUpdate = Date().timeIntervalSince(updated) / 86400.0
        print("📅 [DAYS] \(key): \(String(format: "%.1f", daysSinceUpdate))d in \(status.name) (from updated date)")
        return daysSinceUpdate
    }

    /// Is the issue blocked (flagged OR stagnant for 3+ days)?
    var isBlocked: Bool {
        // Always blocked if flagged
        if isFlagged {
            print("🚫 [BLOCK] \(key) is FLAGGED → BLOCKED")
            return true
        }

        // Don't consider completed/closed issues as blocked
        // even if they're stagnant
        if isCompleted {
            if let days = daysInCurrentStatus, days >= 3.0 {
                print("✅ [BLOCK] \(key) is Done but stagnant (\(String(format: "%.1f", days))d) → NOT BLOCKED (completed)")
            }
            return false
        }

        // Check for stagnation (3+ days without movement)
        if let days = daysInCurrentStatus {
            if days >= 3.0 {
                print("🚫 [BLOCK] \(key) is STAGNANT (\(String(format: "%.1f", days))d in \(status.name)) → BLOCKED")
                return true
            } else {
                print("✅ [BLOCK] \(key) only \(String(format: "%.1f", days))d in \(status.name) → NOT BLOCKED")
            }
        } else {
            print("⚠️ [BLOCK] \(key) has no daysInCurrentStatus → NOT BLOCKED")
        }

        return false
    }

    /// Status where most time was spent
    var slowestStatus: String? {
        guard let history = history else { return nil }
        let durations = history.statusDurations()
        return durations.max(by: { $0.value < $1.value })?.key
    }

    /// Time spent in each status
    var statusDurations: [String: TimeInterval] {
        history?.statusDurations() ?? [:]
    }
}
