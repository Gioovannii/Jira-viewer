//
//  StatusTransition.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Represents a single status transition in an issue's history
struct StatusTransition: Identifiable, Hashable {
    let id: String
    let fromStatus: String
    let toStatus: String
    let transitionDate: Date
    let author: String?
}
