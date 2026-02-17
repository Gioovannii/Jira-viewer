//
//  IssueListViewModel.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

/// ViewModel for the issue list (MVVM pattern)
@MainActor
final class IssueListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var issues: [Issue] = []
    @Published var selectedIssue: Issue?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let fetchIssuesUseCase: FetchIssuesUseCase

    // MARK: - Initialization

    init(fetchIssuesUseCase: FetchIssuesUseCase) {
        self.fetchIssuesUseCase = fetchIssuesUseCase
    }

    // MARK: - Public Methods

    /// Loads issues for an optional sprint
    func loadIssues(sprintId: Int? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            issues = try await fetchIssuesUseCase.execute(sprintId: sprintId)
        } catch {
            errorMessage = "Failed to load tickets: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Selects an issue
    func selectIssue(_ issue: Issue) {
        selectedIssue = issue
    }

    /// Deselects the current issue
    func deselectIssue() {
        selectedIssue = nil
    }
}
