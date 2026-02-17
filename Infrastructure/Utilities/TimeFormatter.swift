//
//  TimeFormatter.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Utility to format durations and cycle times
struct TimeFormatter {
    /// Converts seconds to hours (with 1 decimal place)
    static func secondsToHours(_ seconds: Int) -> String {
        let hours = Double(seconds) / 3600.0
        return String(format: "%.1f", hours)
    }

    /// Converts hours to work days (1 day = 8h)
    static func hoursToDays(_ hours: Double) -> String {
        let days = hours / 8.0
        return String(format: "%.1f", days)
    }

    /// Converts seconds to work days
    static func secondsToDays(_ seconds: Int) -> String {
        let hours = Double(seconds) / 3600.0
        return hoursToDays(hours)
    }

    /// Calculates cycle time in days between two dates
    static func cycleTimeDays(from start: Date, to end: Date) -> String {
        let seconds = end.timeIntervalSince(start)
        let days = seconds / 86400.0 // 86400 seconds in a day
        return String(format: "%.1f", days)
    }

    /// Formats a number of seconds in readable format (Xh Ym)
    static func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "< 1m"
        }
    }
}
