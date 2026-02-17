//
//  JiraSearchResponseDTO.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// DTO for Jira search response (endpoint /search)
struct JiraSearchResponseDTO: Codable {
    let issues: [JiraIssueDTO]
    let total: Int
}
