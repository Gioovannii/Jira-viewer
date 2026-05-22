//
//  OAuthManager.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import AuthenticationServices

/// Manages the OAuth 2.0 flow with Atlassian (3LO — Three-Legged OAuth)
@MainActor
final class OAuthManager: NSObject, ObservableObject {

    // MARK: - Constants

    private enum Atlassian {
        static let clientID = "JbSi9gRhqRgnOjXXDMxQHxxYPHWHaBGJ"
        static let authURL = "https://auth.atlassian.com/authorize"
        static let tokenURL = "https://auth.atlassian.com/oauth/token"
        static let callbackScheme = "jiraviewer"
        static let callbackURL = "jiraviewer://oauth/callback"
        static let scopes = "read:jira-work read:jira-user"
    }

    // MARK: - Published State

    @Published var isAuthenticated = false
    @Published var isAuthenticating = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let secureStorage: SecureStorageProtocol
    private let session = URLSession.shared

    private enum Keys {
        static let accessToken = "oauth_access_token"
        static let refreshToken = "oauth_refresh_token"
        static let cloudID = "atlassian_cloud_id"
    }

    // MARK: - Init

    init(secureStorage: SecureStorageProtocol) {
        self.secureStorage = secureStorage
        super.init()
        isAuthenticated = (try? secureStorage.retrieve(forKey: Keys.accessToken)) != nil
    }

    // MARK: - Public API

    /// Starts the OAuth login flow via ASWebAuthenticationSession
    func login() async {
        print("[OAuth] login() called")
        isAuthenticating = true
        errorMessage = nil

        let state = UUID().uuidString.replacingOccurrences(of: "-", with: "")

        var components = URLComponents(string: Atlassian.authURL)!
        components.queryItems = [
            URLQueryItem(name: "audience", value: "api.atlassian.com"),
            URLQueryItem(name: "client_id", value: Atlassian.clientID),
            URLQueryItem(name: "scope", value: Atlassian.scopes),
            URLQueryItem(name: "redirect_uri", value: Atlassian.callbackURL),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "prompt", value: "consent")
        ]

        guard let authURL = components.url else {
            errorMessage = "Failed to build authorization URL"
            isAuthenticating = false
            return
        }

        do {
            let callbackURL = try await startWebAuthSession(url: authURL)
            let code = try extractCode(from: callbackURL, expectedState: state)
            let tokens = try await exchangeCodeForTokens(code)
            try saveTokens(tokens)
            let cloudID = try await fetchCloudID(accessToken: tokens.accessToken)
            try secureStorage.save(cloudID, forKey: Keys.cloudID)
            isAuthenticated = true
            print("[OAuth] Login successful, cloudID=\(cloudID)")
        } catch {
            errorMessage = error.localizedDescription
            print("[OAuth] Login failed: \(error)")
        }

        isAuthenticating = false
    }

    /// Returns a valid access token, refreshing if needed
    func getValidAccessToken() async throws -> String {
        guard let accessToken = try? secureStorage.retrieve(forKey: Keys.accessToken) else {
            throw OAuthError.notAuthenticated
        }
        return accessToken
    }

    /// Returns the Atlassian Cloud ID
    func getCloudID() throws -> String {
        guard let cloudID = try secureStorage.retrieve(forKey: Keys.cloudID) else {
            throw OAuthError.noCloudID
        }
        return cloudID
    }

    /// Logs out and clears stored tokens
    func logout() {
        try? secureStorage.delete(forKey: Keys.accessToken)
        try? secureStorage.delete(forKey: Keys.refreshToken)
        try? secureStorage.delete(forKey: Keys.cloudID)
        isAuthenticated = false
    }

    // MARK: - Private — Web Auth Session

    private var _webAuthSession: ASWebAuthenticationSession?

    private func startWebAuthSession(url: URL) async throws -> URL {
        print("[OAuth] starting ASWebAuthenticationSession with url=\(url)")
        return try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: Atlassian.callbackScheme
            ) { callbackURL, error in
                if let error = error {
                    print("[OAuth] session error: \(error)")
                    continuation.resume(throwing: OAuthError.authSessionFailed(error))
                    return
                }
                guard let callbackURL = callbackURL else {
                    print("[OAuth] no callback URL")
                    continuation.resume(throwing: OAuthError.noCallbackURL)
                    return
                }
                print("[OAuth] callback received: \(callbackURL)")
                continuation.resume(returning: callbackURL)
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            self._webAuthSession = session
            let started = session.start()
            print("[OAuth] session.start() = \(started)")
        }
    }

    // MARK: - Private — Code Exchange

    private func extractCode(from url: URL, expectedState: String) throws -> String {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw OAuthError.invalidCallback
        }

        if let error = queryItems.first(where: { $0.name == "error" })?.value {
            throw OAuthError.authDenied(error)
        }

        guard let code = queryItems.first(where: { $0.name == "code" })?.value else {
            throw OAuthError.noAuthCode
        }

        return code
    }

    private func exchangeCodeForTokens(_ code: String) async throws -> OAuthTokens {
        var request = URLRequest(url: URL(string: Atlassian.tokenURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "grant_type": "authorization_code",
            "client_id": Atlassian.clientID,
            "code": code,
            "redirect_uri": Atlassian.callbackURL
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            print("[OAuth] Token exchange failed: \(body)")
            throw OAuthError.tokenExchangeFailed
        }

        return try JSONDecoder().decode(OAuthTokens.self, from: data)
    }

    private func saveTokens(_ tokens: OAuthTokens) throws {
        try secureStorage.save(tokens.accessToken, forKey: Keys.accessToken)
        if let refresh = tokens.refreshToken {
            try secureStorage.save(refresh, forKey: Keys.refreshToken)
        }
    }

    // MARK: - Private — Cloud ID

    private func fetchCloudID(accessToken: String) async throws -> String {
        var request = URLRequest(url: URL(string: "https://api.atlassian.com/oauth/token/accessible-resources")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw OAuthError.cloudIDFetchFailed
        }

        let resources = try JSONDecoder().decode([AtlassianResource].self, from: data)
        print("[OAuth] accessible resources: \(resources.map { "\($0.name) (\($0.id))" })")

        guard let resource = resources.first else {
            throw OAuthError.noAtlassianSite
        }

        return resource.id
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension OAuthManager: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        NSApplication.shared.windows.first ?? ASPresentationAnchor()
    }
}

// MARK: - Supporting Types

struct OAuthTokens: Decodable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
}

struct AtlassianResource: Decodable {
    let id: String
    let name: String
    let url: String
}

enum OAuthError: LocalizedError {
    case notAuthenticated
    case noCloudID
    case authSessionFailed(Error)
    case noCallbackURL
    case invalidCallback
    case authDenied(String)
    case noAuthCode
    case tokenExchangeFailed
    case cloudIDFetchFailed
    case noAtlassianSite

    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Not authenticated. Please sign in."
        case .noCloudID: return "Atlassian site not found. Please sign in again."
        case .authSessionFailed(let e): return "Authentication failed: \(e.localizedDescription)"
        case .noCallbackURL: return "No callback URL received."
        case .invalidCallback: return "Invalid callback URL."
        case .authDenied(let reason): return "Access denied: \(reason)"
        case .noAuthCode: return "No authorization code received."
        case .tokenExchangeFailed: return "Failed to exchange code for token."
        case .cloudIDFetchFailed: return "Failed to fetch Atlassian site info."
        case .noAtlassianSite: return "No Atlassian site found for your account."
        }
    }
}
