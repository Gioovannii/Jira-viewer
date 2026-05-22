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
    @ObservedObject private var oauthManager: OAuthManager

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
        oauthManager = container.oauthManager
    }

    var body: some View {
        Group {
            if !oauthManager.isAuthenticated {
                signInView
            } else if showingWelcome && !sprintListViewModel.isConfigured {
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

    // MARK: - Sign In View

    private var signInView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.badge.key.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            Text("JiraViewer")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Sign in with your Atlassian account to get started.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await oauthManager.login() }
            } label: {
                HStack {
                    if oauthManager.isAuthenticating {
                        ProgressView().scaleEffect(0.8)
                    }
                    Text(oauthManager.isAuthenticating ? "Signing in..." : "Sign in with Atlassian")
                        .fontWeight(.semibold)
                }
                .frame(width: 240)
                .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(oauthManager.isAuthenticating)

            if let error = oauthManager.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
                .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Welcome View (project key not set)

    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("One more step")
                .font(.title)
                .fontWeight(.semibold)

            Text("Set your Project Key in Preferences to start.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if #available(macOS 14.0, *) {
                SettingsLink {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Open Preferences")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } label: {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Open Preferences")
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
