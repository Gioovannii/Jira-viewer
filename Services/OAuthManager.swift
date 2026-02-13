import Foundation
import Combine
import CryptoKit

class OAuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var authenticationError: String?

    private let config: OAuthConfig
    private let keychain = KeychainManager.shared
    private var codeVerifier: String?
    private var stateParameter: String?

    private var accessToken: String? {
        didSet {
            isAuthenticated = accessToken != nil
        }
    }
    private var refreshToken: String?
    private var tokenExpirationDate: Date?

    init(config: OAuthConfig = .okta) {
        self.config = config
        loadStoredTokens()
    }

    // MARK: - Load Stored Tokens
    private func loadStoredTokens() {
        do {
            accessToken = try? keychain.retrieve(for: "accessToken")
            refreshToken = try? keychain.retrieve(for: "refreshToken")
            userEmail = try? keychain.retrieve(for: "userEmail")

            if let expirationString = try? keychain.retrieve(for: "tokenExpiration"),
               let expirationTimestamp = Double(expirationString) {
                tokenExpirationDate = Date(timeIntervalSince1970: expirationTimestamp)

                // Check if token is expired
                if let expiration = tokenExpirationDate, expiration < Date() {
                    // Token expired, try to refresh
                    Task {
                        await refreshAccessToken()
                    }
                }
            }
        }
    }

    // MARK: - Start OAuth Flow
    func startOAuthFlow() -> URL? {
        // Generate PKCE parameters
        codeVerifier = generateCodeVerifier()
        guard let codeVerifier = codeVerifier else { return nil }

        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        // Generate state for CSRF protection
        stateParameter = generateRandomString(length: 32)

        // Build authorization URL
        var components = URLComponents(string: config.authorizationEndpoint)
        components?.queryItems = [
            URLQueryItem(name: "client_id", value: config.clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: config.redirectURI),
            URLQueryItem(name: "scope", value: config.scopes.joined(separator: " ")),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "state", value: stateParameter)
        ]

        return components?.url
    }

    // MARK: - Handle OAuth Callback
    func handleCallback(url: URL) async {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            await setError("Invalid callback URL")
            return
        }

        // Extract parameters
        guard let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            await setError("Authorization code not found")
            return
        }

        let state = components.queryItems?.first(where: { $0.name == "state" })?.value

        // Verify state parameter
        guard state == stateParameter else {
            await setError("Invalid state parameter - possible CSRF attack")
            return
        }

        // Exchange code for token
        await exchangeCodeForToken(code: code)
    }

    // MARK: - Exchange Code for Token
    private func exchangeCodeForToken(code: String) async {
        guard let codeVerifier = codeVerifier else {
            await setError("Code verifier missing")
            return
        }

        guard let url = URL(string: config.tokenEndpoint) else {
            await setError("Invalid token endpoint")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters = [
            "grant_type": "authorization_code",
            "client_id": config.clientId,
            "code": code,
            "redirect_uri": config.redirectURI,
            "code_verifier": codeVerifier
        ]

        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                await setError("Invalid response")
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                await setError("Token exchange failed: \(errorMessage)")
                return
            }

            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
            await saveTokens(tokenResponse)

        } catch {
            await setError("Token exchange error: \(error.localizedDescription)")
        }
    }

    // MARK: - Save Tokens
    private func saveTokens(_ tokenResponse: OAuthTokenResponse) async {
        do {
            try keychain.save(value: tokenResponse.accessToken, for: "accessToken")

            if let refreshToken = tokenResponse.refreshToken {
                try keychain.save(value: refreshToken, for: "refreshToken")
                self.refreshToken = refreshToken
            }

            let expirationDate = Date().addingTimeInterval(TimeInterval(tokenResponse.expiresIn))
            try keychain.save(value: String(expirationDate.timeIntervalSince1970), for: "tokenExpiration")
            tokenExpirationDate = expirationDate

            // Decode ID token to get user email
            if let idToken = tokenResponse.idToken {
                if let email = decodeJWT(idToken)?["email"] as? String {
                    try? keychain.save(value: email, for: "userEmail")
                    await MainActor.run {
                        self.userEmail = email
                    }
                }
            }

            await MainActor.run {
                self.accessToken = tokenResponse.accessToken
                self.authenticationError = nil
            }
        } catch {
            await setError("Failed to save tokens: \(error.localizedDescription)")
        }
    }

    // MARK: - Refresh Access Token
    func refreshAccessToken() async {
        guard let refreshToken = refreshToken else {
            await setError("No refresh token available")
            await MainActor.run {
                self.isAuthenticated = false
            }
            return
        }

        guard let url = URL(string: config.tokenEndpoint) else {
            await setError("Invalid token endpoint")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyParameters = [
            "grant_type": "refresh_token",
            "client_id": config.clientId,
            "refresh_token": refreshToken
        ]

        request.httpBody = bodyParameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let tokenResponse = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
            await saveTokens(tokenResponse)
        } catch {
            await setError("Token refresh failed: \(error.localizedDescription)")
            await MainActor.run {
                self.isAuthenticated = false
            }
        }
    }

    // MARK: - Get Valid Access Token
    func getValidAccessToken() async -> String? {
        // Check if token is expired or about to expire (within 5 minutes)
        if let expiration = tokenExpirationDate,
           expiration.timeIntervalSinceNow < 300 {
            await refreshAccessToken()
        }

        return accessToken
    }

    // MARK: - Logout
    func logout() {
        keychain.deleteAll()
        accessToken = nil
        refreshToken = nil
        tokenExpirationDate = nil
        userEmail = nil
        isAuthenticated = false
    }

    // MARK: - Helper Methods
    private func setError(_ message: String) async {
        await MainActor.run {
            self.authenticationError = message
        }
    }

    private func generateCodeVerifier() -> String {
        return generateRandomString(length: 128)
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else { return "" }
        let hash = SHA256.hash(data: data)
        return Data(hash).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func generateRandomString(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map { _ in characters.randomElement()! })
    }

    private func decodeJWT(_ token: String) -> [String: Any]? {
        let segments = token.split(separator: ".")
        guard segments.count > 1 else { return nil }

        var base64 = String(segments[1])
        // Add padding if needed
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }

        base64 = base64
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return json
    }
}
