//
//  MockSprintRepository.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Mock of SprintRepository for testing
final class MockSprintRepository: SprintRepositoryProtocol {
    var sprintsToReturn: [Sprint] = []
    var boardIdToReturn: Int = 1
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.networkFailure(NSError(domain: "test", code: -1))

    var fetchSprintsCalled = false
    var getBoardIdCalled = false

    func fetchSprints(projectKey: String) async throws -> [Sprint] {
        fetchSprintsCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return sprintsToReturn
    }

    func getBoardId(projectKey: String) async throws -> Int {
        getBoardIdCalled = true

        if shouldThrowError {
            throw errorToThrow
        }

        return boardIdToReturn
    }
}
