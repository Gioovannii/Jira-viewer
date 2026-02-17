//
//  ContentView.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Main application view (orchestration)
struct ContentView: View {
    // Injected ViewModels
    @StateObject private var sprintListViewModel: SprintListViewModel
    @StateObject private var issueListViewModel: IssueListViewModel

    // Local state
    @State private var selectedIssue: Issue?
    @State private var showingWelcome = true
    @State private var showSprintReview = true

    init(
        sprintListViewModel: SprintListViewModel? = nil,
        issueListViewModel: IssueListViewModel? = nil
    ) {
        let container = DIContainer.shared
        _sprintListViewModel = StateObject(wrappedValue: sprintListViewModel ?? container.sprintListViewModel)
        _issueListViewModel = StateObject(wrappedValue: issueListViewModel ?? container.issueListViewModel)
    }

    var body: some View {
        Group {
            if !sprintListViewModel.isConfigured && showingWelcome {
                welcomeView
            } else {
                mainView
            }
        }
        .alert(
            "Error",
            isPresented: errorBinding,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text(sprintListViewModel.errorMessage ?? issueListViewModel.errorMessage ?? "Unknown error")
            }
        )
    }

    // MARK: - Welcome View

    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Configuration Required")
                .font(.title)
                .fontWeight(.semibold)

            Text("Please configure your Jira Personal Access Token in preferences")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if #available(macOS 14.0, *) {
                SettingsLink {
                    HStack {
                        Image(systemName: "key.fill")
                        Text("Configure Token")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button(action: {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }) {
                    HStack {
                        Image(systemName: "key.fill")
                        Text("Configure Token")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Main View

    private var mainView: some View {
        NavigationSplitView {
            // Sidebar - Sprint List
            SprintListView(
                viewModel: sprintListViewModel,
                selectedSprint: $sprintListViewModel.selectedSprint
            )
        } content: {
            // Middle - Issue List
            IssueListView(
                viewModel: issueListViewModel,
                selectedIssue: $selectedIssue,
                showSprintReview: $showSprintReview
            )
        } detail: {
            // Detail - Sprint Review or Issue Detail
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: sprintListViewModel.selectedSprint) { newSprint in
            Task {
                await issueListViewModel.loadIssues(sprintId: newSprint?.id)
            }
        }
    }

    // MARK: - Detail View

    @ViewBuilder
    private var detailView: some View {
        if showSprintReview, let sprint = sprintListViewModel.selectedSprint {
            SprintReviewView(
                viewModel: DIContainer.shared.makeSprintReviewViewModel(
                    sprint: sprint,
                    issues: issueListViewModel.issues
                )
            )
        } else if let issue = selectedIssue {
            IssueDetailView(
                viewModel: DIContainer.shared.makeIssueDetailViewModel(issue: issue)
            )
        } else {
            Text("Select an issue or display the sprint summary")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Error Binding

    private var errorBinding: Binding<Bool> {
        Binding(
            get: {
                sprintListViewModel.errorMessage != nil || issueListViewModel.errorMessage != nil
            },
            set: { isPresented in
                if !isPresented {
                    sprintListViewModel.errorMessage = nil
                    issueListViewModel.errorMessage = nil
                }
            }
        )
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 1000, minHeight: 600)
}
