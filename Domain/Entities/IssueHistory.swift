//
//  IssueHistory.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents the complete history of status transitions for an issue
struct IssueHistory: Hashable {
    let transitions: [StatusTransition]

    /// Calculate total time spent in a specific status
    func timeInStatus(_ statusName: String) -> TimeInterval? {
        var totalTime: TimeInterval = 0
        var entryDate: Date?

        for transition in transitions {
            // If entering this status
            if transition.toStatus == statusName {
                entryDate = transition.transitionDate
            }
            // If leaving this status
            else if transition.fromStatus == statusName, let entry = entryDate {
                totalTime += transition.transitionDate.timeIntervalSince(entry)
                entryDate = nil
            }
        }

        return totalTime > 0 ? totalTime : nil
    }

    /// Calculate how long the issue has been in its current status
    func currentStatusDuration(currentStatus: String) -> TimeInterval? {
        // Find the last transition into the current status
        guard let lastEntry = transitions.last(where: { $0.toStatus == currentStatus }) else {
            return nil
        }

        // Check if there's a transition out of this status after the last entry
        let hasExited = transitions.contains { transition in
            transition.fromStatus == currentStatus &&
            transition.transitionDate > lastEntry.transitionDate
        }

        if hasExited {
            return nil
        }

        return Date().timeIntervalSince(lastEntry.transitionDate)
    }

    /// Get all unique statuses the issue has been through
    func allStatuses() -> [String] {
        var statuses = Set<String>()

        for transition in transitions {
            statuses.insert(transition.fromStatus)
            statuses.insert(transition.toStatus)
        }

        return Array(statuses).sorted()
    }

    /// Calculate time spent in each status
    func statusDurations() -> [String: TimeInterval] {
        var durations: [String: TimeInterval] = [:]
        var currentStatus: String?
        var entryDate: Date?

        for transition in transitions.sorted(by: { $0.transitionDate < $1.transitionDate }) {
            // If we're tracking a status, calculate duration before moving to next
            if let status = currentStatus, let entry = entryDate {
                let duration = transition.transitionDate.timeIntervalSince(entry)
                durations[status, default: 0] += duration
            }

            // Move to new status
            currentStatus = transition.toStatus
            entryDate = transition.transitionDate
        }

        // Handle current status (still ongoing)
        if let status = currentStatus, let entry = entryDate {
            let duration = Date().timeIntervalSince(entry)
            durations[status, default: 0] += duration
        }

        return durations
    }
}
