//
//  FetchIssuesUseCase.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Use case to fetch issues for a sprint or project
final class FetchIssuesUseCase {
    private let issueRepository: IssueRepositoryProtocol
    private let configRepository: ConfigRepositoryProtocol

    init(
        issueRepository: IssueRepositoryProtocol,
        configRepository: ConfigRepositoryProtocol
    ) {
        self.issueRepository = issueRepository
        self.configRepository = configRepository
    }

    /// Executes the use case: fetches the issues
    func execute(sprintId: Int? = nil) async throws -> [Issue] {
        let projectKey = configRepository.getProjectKey()
        return try await issueRepository.fetchIssues(projectKey: projectKey, sprintId: sprintId)
    }
}
