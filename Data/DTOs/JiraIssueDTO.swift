//
//  JiraIssueDTO.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// DTO for a Jira Issue (direct JSON mapping)
struct JiraIssueDTO: Codable, Hashable {
    let id: String
    let key: String
    let fields: IssueFieldsDTO
    let changelog: JiraChangelogDTO?

    struct IssueFieldsDTO: Codable, Hashable {
        let summary: String
        let description: String?
        let status: IssueStatusDTO
        let assignee: JiraUserDTO?
        let priority: IssuePriorityDTO?
        let issuetype: IssueTypeDTO
        let created: String?
        let updated: String?
        let resolutiondate: String?
        let sprint: JiraSprintDTO?
        let timetracking: TimeTrackingDTO?
        let customfield_10021: [FlaggedFieldDTO]?

        enum CodingKeys: String, CodingKey {
            case summary, description, status, assignee, priority, issuetype
            case created, updated, resolutiondate, timetracking
            case sprint = "customfield_10020" // Jira custom field for sprint
            case customfield_10021 // Jira custom field for flagged status
        }
    }

    struct FlaggedFieldDTO: Codable, Hashable {
        let value: String
    }

    struct IssueStatusDTO: Codable, Hashable {
        let name: String
    }

    struct JiraUserDTO: Codable, Hashable {
        let displayName: String
        let emailAddress: String?
    }

    struct IssuePriorityDTO: Codable, Hashable {
        let name: String
    }

    struct IssueTypeDTO: Codable, Hashable {
        let name: String
        let iconUrl: String?
    }

    struct TimeTrackingDTO: Codable, Hashable {
        let originalEstimateSeconds: Int?
        let remainingEstimateSeconds: Int?
        let timeSpentSeconds: Int?

        enum CodingKeys: String, CodingKey {
            case originalEstimateSeconds
            case remainingEstimateSeconds
            case timeSpentSeconds
        }
    }
}
