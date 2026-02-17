//
//  IssueType.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira ticket type (pure domain entity)
struct IssueType: Identifiable, Hashable {
    let id: String
    let name: String
    let iconUrl: String?

    init(id: String = UUID().uuidString, name: String, iconUrl: String? = nil) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
    }
}
