//
//  IssueListView.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View for the issue list (middle pane)
struct IssueListView: View {
    @ObservedObject var viewModel: IssueListViewModel
    @Binding var selectedIssue: Issue?
    @Binding var showSprintReview: Bool

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if viewModel.issues.isEmpty {
                Text("No tickets found")
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 0) {
                    Toggle("Show only blocked issues", isOn: $viewModel.showOnlyBlocked)
                        .toggleStyle(.switch)
                        .padding()

                    List(viewModel.filteredIssues, selection: $selectedIssue) { issue in
                        IssueRow(issue: issue)
                            .tag(issue)
                    }
                }
            }
        }
        .navigationTitle("Issues (\(viewModel.filteredIssues.count))")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showSprintReview.toggle()
                    if showSprintReview {
                        selectedIssue = nil
                    }
                }) {
                    Label(
                        showSprintReview ? "Issues" : "Sprint Review",
                        systemImage: showSprintReview ? "list.bullet" : "chart.bar.doc.horizontal"
                    )
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.accentColor)
            }

            if let error = viewModel.errorMessage {
                ToolbarItem(placement: .status) {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .onChange(of: selectedIssue) { newValue in
            if newValue != nil {
                showSprintReview = false
            }
        }
    }

    /// Loads issues for a sprint
    func loadIssues(sprintId: Int?) async {
        await viewModel.loadIssues(sprintId: sprintId)
    }
}

#Preview {
    let container = DIContainer.shared
    let viewModel = container.issueListViewModel

    return NavigationStack {
        IssueListView(
            viewModel: viewModel,
            selectedIssue: .constant(nil),
            showSprintReview: .constant(false)
        )
    }
}
