//
//  User.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira user (pure domain entity)
struct User: Identifiable, Hashable {
    let id: String
    let displayName: String
    let emailAddress: String?

    init(id: String = UUID().uuidString, displayName: String, emailAddress: String? = nil) {
        self.id = id
        self.displayName = displayName
        self.emailAddress = emailAddress
    }
}
