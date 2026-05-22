//
//  JiraAPIClient.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Jira API client using OAuth 2.0 Bearer token (Jira Cloud)
final class JiraAPIClient {
    private let networkClient: NetworkClientProtocol
    private let oauthManager: OAuthManager

    init(networkClient: NetworkClientProtocol, oauthManager: OAuthManager) {
        self.networkClient = networkClient
        self.oauthManager = oauthManager
    }

    func request<T: Decodable>(_ endpoint: JiraEndpoint) async throws -> T {
        let request = try await buildRequest(for: endpoint)
        return try await networkClient.request(request)
    }

    func requestData(_ endpoint: JiraEndpoint) async throws -> Data {
        let request = try await buildRequest(for: endpoint)
        return try await networkClient.requestData(request)
    }

    private func buildRequest(for endpoint: JiraEndpoint) async throws -> URLRequest {
        let cloudID = try await MainActor.run { try oauthManager.getCloudID() }
        let accessToken = try await oauthManager.getValidAccessToken()

        // Jira Cloud REST API via api.atlassian.com
        let baseURL = "https://api.atlassian.com/ex/jira/\(cloudID)"

        guard let url = endpoint.url(baseURL: baseURL) else {
            print("[JiraAPI] ERROR: invalid URL, baseURL=\(baseURL)")
            throw NetworkError.invalidURL
        }

        print("[JiraAPI] \(url)")

        return URLRequestBuilder(url: url)
            .method("GET")
            .bearerAuth(token: accessToken)
            .header("Accept", value: "application/json")
            .timeout(30)
            .build()
    }
}
