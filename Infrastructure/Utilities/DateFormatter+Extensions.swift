//
//  DateFormatter+Extensions.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

extension DateFormatter {
    /// Formatter for ISO8601 dates with milliseconds (Jira format)
    static let jiraISO8601WithFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    /// Formatter for ISO8601 dates without milliseconds (fallback)
    static let jiraISO8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    /// Formatter for display dd/MM/yyyy (French format)
    static let displayFrench: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()

    /// Parses a Jira date (attempts with and without milliseconds)
    static func parseJiraDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        // Try with milliseconds
        if let date = jiraISO8601WithFractional.date(from: dateString) {
            return date
        }

        // Fallback without milliseconds
        return jiraISO8601.date(from: dateString)
    }

    /// Formats a date for French display
    static func formatForDisplay(_ date: Date) -> String {
        return displayFrench.string(from: date)
    }
}
