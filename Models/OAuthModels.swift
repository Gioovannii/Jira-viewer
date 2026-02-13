import Foundation

// MARK: - OAuth Token Response
struct OAuthTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    let scope: String?
    let idToken: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
        case scope
        case idToken = "id_token"
    }
}

// MARK: - OAuth Configuration
struct OAuthConfig {
    let clientId: String
    let authorizationEndpoint: String
    let tokenEndpoint: String
    let redirectURI: String
    let scopes: [String]

    static let okta = OAuthConfig(
        clientId: "YOUR_OKTA_CLIENT_ID", // À configurer
        authorizationEndpoint: "https://YOUR_OKTA_DOMAIN/oauth2/default/v1/authorize",
        tokenEndpoint: "https://YOUR_OKTA_DOMAIN/oauth2/default/v1/token",
        redirectURI: "jiraviewer://oauth-callback",
        scopes: ["openid", "profile", "email", "offline_access"]
    )
}

// MARK: - Auth Method
enum AuthMethod: String, Codable {
    case basicAuth
    case oauth
}
