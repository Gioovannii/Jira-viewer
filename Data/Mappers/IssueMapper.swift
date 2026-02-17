//
//  IssueMapper.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Mapper to convert JiraIssueDTO → Issue (Domain Entity)
struct IssueMapper {
    /// Converts a DTO to a domain entity
    static func toDomain(_ dto: JiraIssueDTO) -> Issue {
        let status = mapStatus(dto.fields.status)
        let assignee = dto.fields.assignee.map { mapUser($0) }
        let priority = dto.fields.priority.map { mapPriority($0) }
        let issueType = mapIssueType(dto.fields.issuetype)
        let created = DateFormatter.parseJiraDate(dto.fields.created)
        let updated = DateFormatter.parseJiraDate(dto.fields.updated)
        let resolved = resolveDate(dto: dto, updated: updated, status: status)
        let sprint = dto.fields.sprint.map { SprintMapper.toDomain($0) }
        let timeTracking = dto.fields.timetracking.map { mapTimeTracking($0) }

        return Issue(
            id: dto.id,
            key: dto.key,
            summary: dto.fields.summary,
            description: dto.fields.description,
            status: status,
            assignee: assignee,
            priority: priority,
            issueType: issueType,
            created: created,
            updated: updated,
            resolved: resolved,
            sprint: sprint,
            timeTracking: timeTracking
        )
    }

    /// Converts a list of DTOs to domain entities
    static func toDomain(_ dtos: [JiraIssueDTO]) -> [Issue] {
        dtos.map { toDomain($0) }
    }

    // MARK: - Private Helpers

    private static func mapStatus(_ dto: JiraIssueDTO.IssueStatusDTO) -> IssueStatus {
        IssueStatus(name: dto.name)
    }

    private static func mapUser(_ dto: JiraIssueDTO.JiraUserDTO) -> User {
        User(displayName: dto.displayName, emailAddress: dto.emailAddress)
    }

    private static func mapPriority(_ dto: JiraIssueDTO.IssuePriorityDTO) -> IssuePriority {
        IssuePriority(name: dto.name)
    }

    private static func mapIssueType(_ dto: JiraIssueDTO.IssueTypeDTO) -> IssueType {
        IssueType(name: dto.name, iconUrl: dto.iconUrl)
    }

    private static func mapTimeTracking(_ dto: JiraIssueDTO.TimeTrackingDTO) -> TimeTracking {
        TimeTracking(
            originalEstimateSeconds: dto.originalEstimateSeconds,
            remainingEstimateSeconds: dto.remainingEstimateSeconds,
            timeSpentSeconds: dto.timeSpentSeconds
        )
    }

    /// Resolution date logic (extracted from JiraModels.swift:21-30)
    private static func resolveDate(
        dto: JiraIssueDTO,
        updated: Date?,
        status: IssueStatus
    ) -> Date? {
        // If resolutiondate exists, use it
        if let resDate = dto.fields.resolutiondate,
           let parsed = DateFormatter.parseJiraDate(resDate) {
            return parsed
        }

        // Fallback: use updated date for "Done" tickets
        let statusName = status.name.lowercased()
        if statusName.contains("done") ||
           statusName.contains("terminé") ||
           statusName.contains("closed") {
            return updated
        }

        return nil
    }
}
