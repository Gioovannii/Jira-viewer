//
//  TimeTracking.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Time tracking for a Jira ticket (pure domain entity)
struct TimeTracking: Hashable {
    let originalEstimateSeconds: Int?
    let remainingEstimateSeconds: Int?
    let timeSpentSeconds: Int?

    init(
        originalEstimateSeconds: Int? = nil,
        remainingEstimateSeconds: Int? = nil,
        timeSpentSeconds: Int? = nil
    ) {
        self.originalEstimateSeconds = originalEstimateSeconds
        self.remainingEstimateSeconds = remainingEstimateSeconds
        self.timeSpentSeconds = timeSpentSeconds
    }

    // MARK: - Computed Properties

    /// Estimated time in hours
    var originalEstimateHours: Double? {
        guard let seconds = originalEstimateSeconds else { return nil }
        return Double(seconds) / 3600.0
    }

    /// Time spent in hours
    var timeSpentHours: Double? {
        guard let seconds = timeSpentSeconds else { return nil }
        return Double(seconds) / 3600.0
    }

    /// Remaining time in hours
    var remainingEstimateHours: Double? {
        guard let seconds = remainingEstimateSeconds else { return nil }
        return Double(seconds) / 3600.0
    }

    /// Completion percentage based on time
    var completionPercentage: Int? {
        guard let original = originalEstimateSeconds,
              let spent = timeSpentSeconds,
              original > 0 else {
            return nil
        }
        return min(Int((Double(spent) / Double(original)) * 100), 100)
    }
}
