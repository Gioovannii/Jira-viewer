//
//  IssueRepositoryProtocol.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Protocol for issue repository (Dependency Inversion)
protocol IssueRepositoryProtocol {
    /// Fetches issues for a project, optionally filtered by sprint
    func fetchIssues(projectKey: String, sprintId: Int?) async throws -> [Issue]
}
