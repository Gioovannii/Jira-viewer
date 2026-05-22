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
        print("[SprintRepo] fetchSprints for projectKey=\(projectKey)")
        let boardId = try await getBoardId(projectKey: projectKey)
        print("[SprintRepo] boardId=\(boardId)")

        let endpoint = JiraEndpoint.sprints(boardId: boardId)
        let response: JiraSprintResponseDTO = try await apiClient.request(endpoint)
        print("[SprintRepo] sprints count=\(response.values.count)")

        return SprintMapper.toDomain(response.values)
    }

    func getBoardId(projectKey: String) async throws -> Int {
        print("[SprintRepo] getBoardId for projectKey=\(projectKey)")
        let endpoint = JiraEndpoint.boards(projectKey: projectKey)
        let response: JiraBoardResponseDTO = try await apiClient.request(endpoint)
        print("[SprintRepo] boards count=\(response.values.count), ids=\(response.values.map(\.id))")

        guard let firstBoard = response.values.first else {
            throw NetworkError.http(
                statusCode: 404,
                message: "No board found for project \(projectKey)"
            )
        }

        return firstBoard.id
    }
}
