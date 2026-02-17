//
//  MockIssueRepository.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Mock of IssueRepository for testing
final class MockIssueRepository: IssueRepositoryProtocol {
    var issuesToReturn: [Issue] = []
    var shouldThrowError = false
    var errorToThrow: Error = NetworkError.networkFailure(NSError(domain: "test", code: -1))

    var fetchIssuesCalled = false
    var lastProjectKey: String?
    var lastSprintId: Int?

    func fetchIssues(projectKey: String, sprintId: Int?) async throws -> [Issue] {
        fetchIssuesCalled = true
        lastProjectKey = projectKey
        lastSprintId = sprintId

        if shouldThrowError {
            throw errorToThrow
        }

        return issuesToReturn
    }
}
