//
//  IssueRow.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View to display an issue row in the list
struct IssueRow: View {
    let issue: Issue

    var priorityColor: Color {
        guard let priority = issue.priority?.name.lowercased() else {
            return .gray
        }

        if priority.contains("highest") || priority.contains("high") {
            return .red
        } else if priority.contains("medium") {
            return .orange
        } else if priority.contains("low") || priority.contains("lowest") {
            return .blue
        }
        return .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(issue.key)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)

                Text(issue.issueType.name)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let priority = issue.priority {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                    Text(priority.name)
                        .font(.caption2)
                        .foregroundColor(priorityColor)
                }
            }

            Text(issue.summary)
                .font(.body)
                .lineLimit(2)

            HStack {
                Label(issue.status.name, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let assignee = issue.assignee {
                    Label(assignee.displayName, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        IssueRow(issue: Issue(
            id: "1",
            key: "PROJ-123",
            summary: "Implement clean architecture with DTOs",
            status: IssueStatus(name: "In Progress"),
            assignee: User(displayName: "John Doe"),
            priority: IssuePriority(name: "High"),
            issueType: IssueType(name: "Story")
        ))
        IssueRow(issue: Issue(
            id: "2",
            key: "PROJ-124",
            summary: "Fix date parsing bug",
            status: IssueStatus(name: "Done"),
            assignee: User(displayName: "Jane Smith"),
            priority: IssuePriority(name: "Medium"),
            issueType: IssueType(name: "Bug")
        ))
    }
}
