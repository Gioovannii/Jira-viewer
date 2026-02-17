//
//  JiraEndpoint.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Enum representing Jira API endpoints
enum JiraEndpoint {
    case boards(projectKey: String)
    case sprints(boardId: Int)
    case searchIssues(jql: String, maxResults: Int, fields: [String], expand: [String]?)

    /// Builds the relative path for the endpoint
    func path(baseURL: String) -> String {
        let base = baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))

        switch self {
        case .boards:
            return "\(base)/rest/agile/1.0/board"
        case .sprints(let boardId):
            return "\(base)/rest/agile/1.0/board/\(boardId)/sprint"
        case .searchIssues:
            return "\(base)/rest/api/2/search"
        }
    }

    /// Builds the complete URL with query parameters
    func url(baseURL: String) -> URL? {
        let pathString = path(baseURL: baseURL)

        guard var components = URLComponents(string: pathString) else {
            return nil
        }

        // Add query parameters based on the endpoint
        switch self {
        case .boards(let projectKey):
            components.queryItems = [
                URLQueryItem(name: "projectKeyOrId", value: projectKey)
            ]
        case .sprints:
            // No query params
            break
        case .searchIssues(let jql, let maxResults, let fields, let expand):
            var queryItems = [
                URLQueryItem(name: "jql", value: jql),
                URLQueryItem(name: "maxResults", value: "\(maxResults)"),
                URLQueryItem(name: "fields", value: fields.joined(separator: ","))
            ]
            if let expand = expand, !expand.isEmpty {
                queryItems.append(URLQueryItem(name: "expand", value: expand.joined(separator: ",")))
            }
            components.queryItems = queryItems
        }

        return components.url
    }
}
