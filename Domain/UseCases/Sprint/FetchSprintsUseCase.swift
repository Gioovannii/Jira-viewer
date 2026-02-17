//
//  FetchSprintsUseCase.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Use case to fetch and sort sprints
final class FetchSprintsUseCase {
    private let sprintRepository: SprintRepositoryProtocol
    private let configRepository: ConfigRepositoryProtocol

    init(
        sprintRepository: SprintRepositoryProtocol,
        configRepository: ConfigRepositoryProtocol
    ) {
        self.sprintRepository = sprintRepository
        self.configRepository = configRepository
    }

    /// Executes the use case: fetches sprints and sorts them (active ones first)
    func execute() async throws -> [Sprint] {
        let projectKey = configRepository.getProjectKey()
        let sprints = try await sprintRepository.fetchSprints(projectKey: projectKey)

        // Business logic: sort sprints
        // - Active ones first
        // - Then by descending start date (most recent first)
        return sprints.sorted { sprint1, sprint2 in
            // Priority to active sprints
            if sprint1.isActive && !sprint2.isActive {
                return true
            }
            if !sprint1.isActive && sprint2.isActive {
                return false
            }

            // Otherwise, sort by start date (most recent first)
            if let date1 = sprint1.startDate, let date2 = sprint2.startDate {
                return date1 > date2
            }

            // Fallback to ID if no dates
            return sprint1.id > sprint2.id
        }
    }
}
