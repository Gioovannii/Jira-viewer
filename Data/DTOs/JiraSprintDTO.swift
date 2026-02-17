//
//  JiraSprintDTO.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// DTO for a Jira Sprint (direct JSON mapping)
struct JiraSprintDTO: Codable, Hashable {
    let id: Int
    let name: String
    let state: String
    let startDate: String?
    let endDate: String?
    let goal: String?
}

/// DTO for the sprints API response
struct JiraSprintResponseDTO: Codable {
    let values: [JiraSprintDTO]
}
