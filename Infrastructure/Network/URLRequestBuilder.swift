//
//  URLRequestBuilder.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Builder to construct URLRequest with a fluent API
struct URLRequestBuilder {
    private var urlRequest: URLRequest

    init(url: URL) {
        self.urlRequest = URLRequest(url: url)
    }

    func method(_ method: String) -> URLRequestBuilder {
        var builder = self
        builder.urlRequest.httpMethod = method
        return builder
    }

    func header(_ key: String, value: String) -> URLRequestBuilder {
        var builder = self
        builder.urlRequest.setValue(value, forHTTPHeaderField: key)
        return builder
    }

    func bearerAuth(token: String) -> URLRequestBuilder {
        return header("Authorization", value: "Bearer \(token)")
    }

    func basicAuth(username: String, password: String) -> URLRequestBuilder {
        let credentials = "\(username):\(password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            return self
        }
        let base64Credentials = credentialsData.base64EncodedString()
        return header("Authorization", value: "Basic \(base64Credentials)")
    }

    func contentType(_ contentType: String) -> URLRequestBuilder {
        return header("Content-Type", value: contentType)
    }

    func body(_ data: Data) -> URLRequestBuilder {
        var builder = self
        builder.urlRequest.httpBody = data
        return builder
    }

    func timeout(_ seconds: TimeInterval) -> URLRequestBuilder {
        var builder = self
        builder.urlRequest.timeoutInterval = seconds
        return builder
    }

    func build() -> URLRequest {
        return urlRequest
    }
}
