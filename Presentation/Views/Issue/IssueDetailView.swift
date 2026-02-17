//
//  IssueDetailView.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View to display issue details
struct IssueDetailView: View {
    @ObservedObject var viewModel: IssueDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection

                Divider()

                // Details
                detailsSection

                // Blockage Warning
                if viewModel.issue.isBlocked {
                    Divider()

                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(viewModel.blockageInfo ?? "Blocked")
                            .foregroundColor(.red)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }

                // Status History Timeline
                if let history = viewModel.issue.history, !history.transitions.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Status History")
                            .font(.headline)

                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.statusHistory, id: \.status) { item in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                        .padding(.top, 6)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.status)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text(item.duration)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(item.date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }
                            }
                        }
                    }
                }

                // Description
                if let description = viewModel.issue.description, !description.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)

                        Text(description)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(viewModel.issue.key)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    viewModel.openInJira()
                }) {
                    Label("Open in Jira", systemImage: "arrow.up.right.square")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.accentColor)
            }

            Text(viewModel.issue.summary)
                .font(.title3)
        }
    }

    // MARK: - Details Section

    private var detailsSection: some View {
        Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
            GridRow {
                Text("Status:")
                    .fontWeight(.semibold)
                Text(viewModel.issue.status.name)
            }

            GridRow {
                Text("Type:")
                    .fontWeight(.semibold)
                Text(viewModel.issue.issueType.name)
            }

            if let priority = viewModel.issue.priority {
                GridRow {
                    Text("Priority:")
                        .fontWeight(.semibold)
                    Text(priority.name)
                }
            }

            if let assignee = viewModel.issue.assignee {
                GridRow {
                    Text("Assigned to:")
                        .fontWeight(.semibold)
                    Text(assignee.displayName)
                }
            }

            if let createdDate = viewModel.createdDateFormatted {
                GridRow {
                    Text("Created on:")
                        .fontWeight(.semibold)
                    Text(createdDate)
                }
            }

            if let updatedDate = viewModel.updatedDateFormatted {
                GridRow {
                    Text("Updated on:")
                        .fontWeight(.semibold)
                    Text(updatedDate)
                }
            }

            if let resolvedDate = viewModel.resolvedDateFormatted {
                GridRow {
                    Text("Resolved on:")
                        .fontWeight(.semibold)
                    Text(resolvedDate)
                }
            }

            if let cycleTime = viewModel.issue.cycleTimeFormatted {
                GridRow {
                    Text("Cycle time:")
                        .fontWeight(.semibold)
                    Text(cycleTime)
                }
            }
        }
    }
}

#Preview {
    let issue = Issue(
        id: "1",
        key: "PROJ-123",
        summary: "Implement clean architecture",
        description: "This task consists of refactoring the code towards a clean architecture with separation of Domain, Data and Presentation layers.",
        status: IssueStatus(name: "In Progress"),
        assignee: User(displayName: "John Doe", emailAddress: "john@example.com"),
        priority: IssuePriority(name: "High"),
        issueType: IssueType(name: "Story"),
        created: Date().addingTimeInterval(-86400 * 5),
        updated: Date()
    )

    let viewModel = DIContainer.shared.makeIssueDetailViewModel(issue: issue)

    return IssueDetailView(viewModel: viewModel)
}
