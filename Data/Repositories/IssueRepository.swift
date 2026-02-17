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
            "customfield_10021", // Flagged
            "timetracking"
        ]

        // 3. Execute the request (with changelog expansion)
        let endpoint = JiraEndpoint.searchIssues(
            jql: jql,
            maxResults: 100,
            fields: fields,
            expand: ["changelog"]
        )
        let response: JiraSearchResponseDTO = try await apiClient.request(endpoint)

        // 4. Map DTOs to domain entities
        let issues = IssueMapper.toDomain(response.issues)

        // Debug: Summary
        let blockedCount = issues.filter { $0.isBlocked }.count
        let withHistoryCount = issues.filter { $0.history != nil && !$0.history!.transitions.isEmpty }.count
        print("📊 [DEBUG] ===== SUMMARY =====")
        print("📊 [DEBUG] Fetched: \(issues.count) issues")
        print("📊 [DEBUG] With status transitions: \(withHistoryCount)")
        print("🚫 [DEBUG] Blocked issues detected: \(blockedCount)")
        print("📊 [DEBUG] ==================")

        return issues
    }
}
