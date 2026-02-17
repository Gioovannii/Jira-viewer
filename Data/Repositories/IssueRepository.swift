//
//  IssueRepository.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Issue repository implementation
final class IssueRepository: IssueRepositoryProtocol {
    private let apiClient: JiraAPIClient

    init(apiClient: JiraAPIClient) {
        self.apiClient = apiClient
    }

    // MARK: - IssueRepositoryProtocol

    func fetchIssues(projectKey: String, sprintId: Int?) async throws -> [Issue] {
        // 1. Build the JQL query
        let jql: String
        if let sprintId = sprintId {
            jql = "project = \(projectKey) AND sprint = \(sprintId) ORDER BY created DESC"
        } else {
            jql = "project = \(projectKey) ORDER BY created DESC"
        }

        // 2. Define the fields to fetch
        let fields = [
            "summary",
            "description",
            "status",
            "assignee",
            "priority",
            "issuetype",
            "created",
            "updated",
            "resolutiondate",
            "customfield_10020", // Sprint
            "timetracking"
        ]

        // 3. Execute the request
        let endpoint = JiraEndpoint.searchIssues(jql: jql, maxResults: 100, fields: fields)
        let response: JiraSearchResponseDTO = try await apiClient.request(endpoint)

        // 4. Map DTOs to domain entities
        return IssueMapper.toDomain(response.issues)
    }
}
