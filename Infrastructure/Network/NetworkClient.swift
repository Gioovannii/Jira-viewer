//
//  NetworkClient.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Protocol to abstract the network client (testable with mock)
protocol NetworkClientProtocol {
    func request<T: Decodable>(_ request: URLRequest) async throws -> T
    func requestData(_ request: URLRequest) async throws -> Data
}

/// Generic network client using URLSession
final class NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    /// Performs a request and decodes the JSON response to type T
    func request<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data = try await requestData(request)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    /// Performs a request and returns raw data
    func requestData(_ request: URLRequest) async throws -> Data {
        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NetworkError.networkFailure(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidURL
        }

        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw NetworkError.unauthorized
        default:
            let message = decodeErrorMessage(from: data) ??
                HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NetworkError.http(statusCode: httpResponse.statusCode, message: message)
        }
    }

    /// Attempts to decode an error message from Jira JSON
    private func decodeErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        // Jira format: {"errorMessages": ["message"], "errors": {"field": "error"}}
        if let messages = json["errorMessages"] as? [String], !messages.isEmpty {
            return messages.joined(separator: " ")
        }

        if let errors = json["errors"] as? [String: Any], !errors.isEmpty {
            let pairs = errors.map { "\($0.key): \($0.value)" }.sorted()
            return pairs.joined(separator: " ")
        }

        return nil
    }
}
