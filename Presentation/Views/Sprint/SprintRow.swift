//
//  SprintRow.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View to display a sprint row in the list
struct SprintRow: View {
    let sprint: Sprint

    var statusColor: Color {
        switch sprint.state {
        case .active: return .green
        case .closed: return .gray
        case .future: return .blue
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(sprint.name)
                    .font(.headline)
                Spacer()
                Text(sprint.state.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }

            if let goal = sprint.goal, !goal.isEmpty {
                Text(goal)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            if let startDate = sprint.startDate, let endDate = sprint.endDate {
                Text("\(formatDate(startDate)) - \(formatDate(endDate))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        DateFormatter.formatForDisplay(date)
    }
}

#Preview {
    List {
        SprintRow(sprint: Sprint(
            id: 1,
            name: "Sprint 25",
            state: .active,
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 14),
            goal: "Implement clean architecture"
        ))
        SprintRow(sprint: Sprint(
            id: 2,
            name: "Sprint 24",
            state: .closed,
            startDate: Date().addingTimeInterval(-86400 * 14),
            endDate: Date(),
            goal: "Refactor du code legacy"
        ))
    }
}
