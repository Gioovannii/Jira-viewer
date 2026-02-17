//
//  SprintRepository.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Sprint repository implementation
final class SprintRepository: SprintRepositoryProtocol {
    private let apiClient: JiraAPIClient

    init(apiClient: JiraAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - SprintRepositoryProtocol

    func fetchSprints(projectKey: String) async throws -> [Sprint] {
        // 1. Fetch the board ID
        let boardId = try await getBoardId(projectKey: projectKey)

        // 2. Fetch the board's sprints
        let endpoint = JiraEndpoint.sprints(boardId: boardId)
        let response: JiraSprintResponseDTO = try await apiClient.request(endpoint)

        // 3. Map DTOs to domain entities
        return SprintMapper.toDomain(response.values)
    }

    func getBoardId(projectKey: String) async throws -> Int {
        let endpoint = JiraEndpoint.boards(projectKey: projectKey)
        let response: JiraBoardResponseDTO = try await apiClient.request(endpoint)

        guard let firstBoard = response.values.first else {
            throw NetworkError.http(
                statusCode: 404,
                message: "No board found for project \(projectKey)"
            )
        }

        return firstBoard.id
    }
}
