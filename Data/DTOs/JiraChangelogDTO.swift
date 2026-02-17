//
//  JiraChangelogDTO.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira API changelog response
struct JiraChangelogDTO: Codable, Hashable {
    let histories: [HistoryItem]

    struct HistoryItem: Codable, Hashable {
        let id: String
        let created: String
        let author: Author?
        let items: [ChangeItem]
    }

    struct ChangeItem: Codable, Hashable {
        let field: String
        let fieldtype: String
        let from: String?
        let fromString: String?
        let to: String?
        let toString: String?
    }

    struct Author: Codable, Hashable {
        let displayName: String
    }
}
