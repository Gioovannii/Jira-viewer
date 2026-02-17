//
//  IssueStatus.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira ticket status (pure domain entity)
struct IssueStatus: Identifiable, Hashable {
    let id: String
    let name: String

    init(id: String = UUID().uuidString, name: String) {
        self.id = id
        self.name = name
    }
}
