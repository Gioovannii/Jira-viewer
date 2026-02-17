//
//  IssueHistoryMapper.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Maps Jira changelog DTO to domain IssueHistory entity
enum IssueHistoryMapper {
    /// Map changelog DTO to IssueHistory domain entity
    static func map(changelogDTO: JiraChangelogDTO) -> IssueHistory {
        print("📊 [DEBUG] Changelog has \(changelogDTO.histories.count) history items")
        if changelogDTO.histories.count > 0 {
            print("📊 [DEBUG] First history item has \(changelogDTO.histories[0].items.count) changes")
            if changelogDTO.histories[0].items.count > 0 {
                print("📊 [DEBUG] First change field: \(changelogDTO.histories[0].items[0].field)")
            }
        }
        let transitions = extractStatusTransitions(from: changelogDTO.histories)
        return IssueHistory(transitions: transitions)
    }

    /// Extract only status transitions from all history items
    private static func extractStatusTransitions(
        from histories: [JiraChangelogDTO.HistoryItem]
    ) -> [StatusTransition] {
        var transitions: [StatusTransition] = []

        // Debug: Log all unique field names
        let allFields = Set(histories.flatMap { $0.items.map { $0.field } })
        print("📊 [DEBUG] All changelog fields: \(allFields.sorted().joined(separator: ", "))")

        for history in histories {
            // Filter for status changes (try both lowercase and capitalized)
            let statusChanges = history.items.filter {
                $0.field.lowercased() == "status"
            }

            for change in statusChanges {
                guard let fromString = change.fromString,
                      let toString = change.toString else {
                    continue
                }

                // Parse the date
                guard let date = ISO8601DateFormatter().date(from: history.created) else {
                    continue
                }

                let transition = StatusTransition(
                    id: "\(history.id)-\(change.field)",
                    fromStatus: fromString,
                    toStatus: toString,
                    transitionDate: date,
                    author: history.author?.displayName
                )

                transitions.append(transition)
            }
        }

        // Sort by date
        return transitions.sorted { $0.transitionDate < $1.transitionDate }
    }
}
