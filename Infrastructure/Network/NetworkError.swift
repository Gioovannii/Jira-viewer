//
//  NetworkError.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Typed network errors for Clean Architecture
enum NetworkError: LocalizedError {
    case invalidURL
    case unauthorized
    case http(statusCode: Int, message: String)
    case decodingFailed(Error)
    case networkFailure(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .unauthorized:
            return "Unauthorized. Check your authentication token"
        case .http(let statusCode, let message):
            return "HTTP Error \(statusCode): \(message)"
        case .decodingFailed(let error):
            return "JSON decoding failed: \(error.localizedDescription)"
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        case .noData:
            return "No data received from server"
        }
    }
}
