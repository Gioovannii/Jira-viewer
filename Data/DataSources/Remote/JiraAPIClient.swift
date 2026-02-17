//
//  JiraAPIClient.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira-specific API client (adds Bearer Token authentication)
final class JiraAPIClient {
    private let networkClient: NetworkClientProtocol
    private let configRepository: ConfigRepositoryProtocol

    init(
        networkClient: NetworkClientProtocol,
        configRepository: ConfigRepositoryProtocol
    ) {
        self.networkClient = networkClient
        self.configRepository = configRepository
    }

    /// Performs a GET request on a Jira endpoint with authentication
    func request<T: Decodable>(_ endpoint: JiraEndpoint) async throws -> T {
        let baseURL = configRepository.getJiraBaseURL()

        guard let url = endpoint.url(baseURL: baseURL) else {
            throw NetworkError.invalidURL
        }

        guard let token = configRepository.getJiraToken(), !token.isEmpty else {
            throw NetworkError.unauthorized
        }

        let request = URLRequestBuilder(url: url)
            .method("GET")
            .bearerAuth(token: token)
            .timeout(30)
            .build()

        return try await networkClient.request(request)
    }

    /// Performs a GET request and returns raw data
    func requestData(_ endpoint: JiraEndpoint) async throws -> Data {
        let baseURL = configRepository.getJiraBaseURL()

        guard let url = endpoint.url(baseURL: baseURL) else {
            throw NetworkError.invalidURL
        }

        guard let token = configRepository.getJiraToken(), !token.isEmpty else {
            throw NetworkError.unauthorized
        }

        let request = URLRequestBuilder(url: url)
            .method("GET")
            .bearerAuth(token: token)
            .timeout(30)
            .build()

        return try await networkClient.requestData(request)
    }
}
