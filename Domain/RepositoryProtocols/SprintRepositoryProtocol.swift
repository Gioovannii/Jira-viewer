//
//  SprintRepositoryProtocol.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Protocol for sprint repository (Dependency Inversion)
protocol SprintRepositoryProtocol {
    /// Fetches the list of sprints for a project
    func fetchSprints(projectKey: String) async throws -> [Sprint]

    /// Fetches the Jira board ID for a project
    func getBoardId(projectKey: String) async throws -> Int
}
