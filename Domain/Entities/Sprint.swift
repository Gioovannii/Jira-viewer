//
//  Sprint.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira sprint (pure domain entity)
struct Sprint: Identifiable, Hashable {
    let id: Int
    let name: String
    let state: SprintState
    let startDate: Date?
    let endDate: Date?
    let goal: String?

    init(
        id: Int,
        name: String,
        state: SprintState,
        startDate: Date? = nil,
        endDate: Date? = nil,
        goal: String? = nil
    ) {
        self.id = id
        self.name = name
        self.state = state
        self.startDate = startDate
        self.endDate = endDate
        self.goal = goal
    }

    // MARK: - Computed Properties

    /// Is the sprint active?
    var isActive: Bool {
        state == .active
    }

    /// Is the sprint closed?
    var isClosed: Bool {
        state == .closed
    }

    /// Is the sprint future?
    var isFuture: Bool {
        state == .future
    }

    /// Sprint duration in days
    var durationDays: Int? {
        guard let start = startDate, let end = endDate else {
            return nil
        }
        let seconds = end.timeIntervalSince(start)
        return Int(seconds / 86400) // 86400 seconds per day
    }
}

/// Sprint state
enum SprintState: String, Hashable {
    case active
    case closed
    case future

    var displayName: String {
        rawValue.capitalized
    }
}
