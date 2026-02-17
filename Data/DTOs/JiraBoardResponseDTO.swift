//
//  JiraBoardResponseDTO.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// DTO for Jira boards response (endpoint /board)
struct JiraBoardResponseDTO: Codable {
    let values: [BoardDTO]

    struct BoardDTO: Codable {
        let id: Int
        let name: String
    }
}
