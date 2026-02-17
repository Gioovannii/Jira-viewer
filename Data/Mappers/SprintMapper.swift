//
//  SprintMapper.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Mapper to convert JiraSprintDTO → Sprint (Domain Entity)
struct SprintMapper {
    /// Converts a DTO to a domain entity
    static func toDomain(_ dto: JiraSprintDTO) -> Sprint {
        let state = mapState(dto.state)
        let startDate = DateFormatter.parseJiraDate(dto.startDate)
        let endDate = DateFormatter.parseJiraDate(dto.endDate)

        return Sprint(
            id: dto.id,
            name: dto.name,
            state: state,
            startDate: startDate,
            endDate: endDate,
            goal: dto.goal
        )
    }

    /// Converts a list of DTOs to domain entities
    static func toDomain(_ dtos: [JiraSprintDTO]) -> [Sprint] {
        dtos.map { toDomain($0) }
    }

    // MARK: - Private Helpers

    private static func mapState(_ stateString: String) -> SprintState {
        switch stateString.lowercased() {
        case "active":
            return .active
        case "closed":
            return .closed
        case "future":
            return .future
        default:
            return .future // Fallback
        }
    }
}
