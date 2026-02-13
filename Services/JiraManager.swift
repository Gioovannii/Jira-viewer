import Foundation
import Combine

class JiraManager: ObservableObject {
    @Published var issues: [JiraIssue] = []
    @Published var sprints: [Sprint] = []
    @Published var selectedSprint: Sprint?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var summaries: [String: IssueSummary] = [:]

    var oauthManager: OAuthManager?

    var jiraBaseURL: String {
        UserDefaults.standard.string(forKey: "jiraBaseURL") ?? ""
    }

    private var jiraUsername: String {
        UserDefaults.standard.string(forKey: "jiraUsername") ?? ""
    }

    private var jiraToken: String {
        UserDefaults.standard.string(forKey: "jiraToken") ?? ""
    }

    private var claudeAPIKey: String {
        UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
    }

    private var projectKey: String {
        UserDefaults.standard.string(forKey: "projectKey") ?? ""
    }

    private var authMethod: AuthMethod {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: "authMethod"),
               let method = AuthMethod(rawValue: rawValue) {
                return method
            }
            return .basicAuth
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "authMethod")
        }
    }

    var isConfigured: Bool {
        if authMethod == .oauth {
            return oauthManager?.isAuthenticated == true && !jiraBaseURL.isEmpty && !projectKey.isEmpty
        } else {
            return !jiraBaseURL.isEmpty && !jiraUsername.isEmpty && !jiraToken.isEmpty && !projectKey.isEmpty
        }
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Add Authentication
    private func addAuthentication(to request: inout URLRequest) async -> Bool {
        if authMethod == .oauth {
            guard let token = await oauthManager?.getValidAccessToken() else {
                await MainActor.run {
                    errorMessage = "Authentification OAuth requise. Veuillez vous connecter."
                }
                return false
            }
            request.addBearerAuth(token: token)
        } else {
            request.addBasicAuth(username: jiraUsername, token: jiraToken)
        }
        return true
    }

    private enum JiraError: LocalizedError {
        case configuration(String)
        case invalidResponse(String)
        case http(statusCode: Int, message: String)

        var errorDescription: String? {
            switch self {
            case .configuration(let message):
                return message
            case .invalidResponse(let message):
                return message
            case .http(let statusCode, let message):
                return "HTTP \(statusCode): \(message)"
            }
        }
    }

    private func validateConfiguration() async -> Bool {
        if jiraBaseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await MainActor.run {
                errorMessage = "URL Jira manquante"
            }
            return false
        }
        if jiraUsername.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await MainActor.run {
                errorMessage = "Nom d'utilisateur Jira manquant"
            }
            return false
        }
        if jiraToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await MainActor.run {
                errorMessage = "Token / mot de passe Jira manquant"
            }
            return false
        }
        if projectKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await MainActor.run {
                errorMessage = "Clé de projet Jira manquante"
            }
            return false
        }
        return true
    }

    private func decodeJiraError(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        if let messages = json["errorMessages"] as? [String], !messages.isEmpty {
            return messages.joined(separator: " ")
        }
        if let errors = json["errors"] as? [String: Any], !errors.isEmpty {
            let pairs = errors.map { "\($0.key): \($0.value)" }.sorted()
            return pairs.joined(separator: " ")
        }
        return nil
    }

    // MARK: - Fetch Sprints
    func fetchSprints() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        guard await validateConfiguration() else {
            await MainActor.run {
                isLoading = false
            }
            return
        }

        // For Jira Server, we need to get the board ID first
        let boardId: Int?
        do {
            boardId = try await getBoardId()
        } catch {
            await MainActor.run {
                self.sprints = []
                self.selectedSprint = nil
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
            // Still allow fetching issues without sprint/board
            await fetchIssues(for: nil)
            return
        }

        guard let boardId else {
            await MainActor.run {
                self.sprints = []
                self.selectedSprint = nil
                self.isLoading = false
                self.errorMessage = "Aucun board Jira trouvé pour le projet \(projectKey)"
            }
            await fetchIssues(for: nil)
            return
        }

        let urlString = "\(jiraBaseURL)/rest/agile/1.0/board/\(boardId)/sprint"
        guard let url = URL(string: urlString) else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Invalid URL"
            }
            return
        }

        var request = URLRequest(url: url)
        guard await addAuthentication(to: &request) else {
            await MainActor.run {
                isLoading = false
            }
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw JiraError.invalidResponse("Réponse HTTP invalide")
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let details = decodeJiraError(from: data)
                    ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                throw JiraError.http(statusCode: httpResponse.statusCode, message: details)
            }

            let sprintResponse = try JSONDecoder().decode(JiraSprintResponse.self, from: data)

            await MainActor.run {
                self.sprints = sprintResponse.values.sorted { $0.id > $1.id }
                if selectedSprint == nil, let first = sprints.first(where: { $0.state == "active" }) {
                    selectedSprint = first
                }
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Échec chargement des sprints: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    // MARK: - Fetch Issues for Sprint
    func fetchIssues(for sprint: Sprint?) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        guard await validateConfiguration() else {
            await MainActor.run {
                isLoading = false
            }
            return
        }

        let jql: String
        if let sprint = sprint {
            jql = "project = \(projectKey) AND sprint = \(sprint.id) ORDER BY created DESC"
        } else {
            jql = "project = \(projectKey) ORDER BY created DESC"
        }

        let urlString = "\(jiraBaseURL)/rest/api/2/search"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "jql", value: jql),
            URLQueryItem(name: "maxResults", value: "100"),
            URLQueryItem(name: "fields", value: "summary,description,status,assignee,priority,issuetype,created,customfield_10020")
        ]

        guard let url = components.url else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Invalid URL"
            }
            return
        }

        var request = URLRequest(url: url)
        guard await addAuthentication(to: &request) else {
            await MainActor.run {
                isLoading = false
            }
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw JiraError.invalidResponse("Réponse HTTP invalide")
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let details = decodeJiraError(from: data)
                    ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                throw JiraError.http(statusCode: httpResponse.statusCode, message: details)
            }

            let searchResponse = try JSONDecoder().decode(JiraSearchResponse.self, from: data)

            await MainActor.run {
                self.issues = searchResponse.issues
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Échec chargement des tickets: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    // MARK: - Get Board ID
    private func getBoardId() async throws -> Int {
        let urlString = "\(jiraBaseURL)/rest/agile/1.0/board"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "projectKeyOrId", value: projectKey)
        ]

        guard let url = components.url else {
            throw JiraError.invalidResponse("URL Jira invalide")
        }

        var request = URLRequest(url: url)
        guard await addAuthentication(to: &request) else {
            throw JiraError.configuration("Authentification échouée")
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw JiraError.invalidResponse("Réponse HTTP invalide")
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                let details = decodeJiraError(from: data)
                    ?? HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                throw JiraError.http(statusCode: httpResponse.statusCode, message: details)
            }
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let values = json?["values"] as? [[String: Any]]
            if let boardId = values?.first?["id"] as? Int {
                return boardId
            }
            throw JiraError.invalidResponse("Aucun board trouvé pour le projet \(projectKey)")
        } catch {
            throw error
        }
    }

    // MARK: - Generate Summary with Claude
    func generateSummary(for issue: JiraIssue) async {
        guard !claudeAPIKey.isEmpty else {
            await MainActor.run {
                errorMessage = "Claude API key not configured"
            }
            return
        }

        let prompt = """
        Génère un résumé concis et clair de ce ticket Jira en français:

        Titre: \(issue.summary)
        Type: \(issue.issueType)
        Status: \(issue.status)
        Description: \(issue.description ?? "Aucune description")

        Le résumé doit être en 2-3 phrases maximum et mettre en évidence les points clés.
        """

        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 300,
            "messages": [
                [
                    "role": "user",
                    "content": prompt
                ]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            if let content = json?["content"] as? [[String: Any]],
               let text = content.first?["text"] as? String {

                let summary = IssueSummary(
                    id: issue.id,
                    issueKey: issue.key,
                    summary: text,
                    generatedAt: Date()
                )

                await MainActor.run {
                    self.summaries[issue.key] = summary
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to generate summary: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - URLRequest Extension
extension URLRequest {
    mutating func addBasicAuth(username: String, token: String) {
        let credentials = "\(username):\(token)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
    }

    mutating func addBearerAuth(token: String) {
        setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
