import Foundation
import Combine

class JiraManager: ObservableObject {
    @Published var issues: [JiraIssue] = []
    @Published var sprints: [Sprint] = []
    @Published var selectedSprint: Sprint?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var summaries: [String: IssueSummary] = [:]

    var jiraBaseURL: String {
        UserDefaults.standard.string(forKey: "jiraBaseURL") ?? "https://jira.ets.mpi-internal.com"
    }

    private var jiraToken: String {
        UserDefaults.standard.string(forKey: "jiraToken") ?? ""
    }

    private var claudeAPIKey: String {
        UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
    }

    private var projectKey: String {
        UserDefaults.standard.string(forKey: "projectKey") ?? "LBCMONSPE"
    }

    var isConfigured: Bool {
        return !jiraToken.isEmpty && !jiraBaseURL.isEmpty && !projectKey.isEmpty
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Add Authentication
    private func addAuthentication(to request: inout URLRequest) async -> Bool {
        guard !jiraToken.isEmpty else {
            await MainActor.run {
                errorMessage = "Token manquant. Veuillez configurer votre Personal Access Token."
            }
            return false
        }
        request.addBearerAuth(token: jiraToken)
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
        if jiraToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await MainActor.run {
                errorMessage = "Personal Access Token manquant"
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
                // Trier les sprints: actifs d'abord, puis par date de début décroissante
                self.sprints = sprintResponse.values.sorted { sprint1, sprint2 in
                    // Priorité aux sprints actifs
                    if sprint1.state == "active" && sprint2.state != "active" {
                        return true
                    }
                    if sprint1.state != "active" && sprint2.state == "active" {
                        return false
                    }
                    // Sinon, trier par date de début (plus récent en premier)
                    if let date1 = sprint1.startDate, let date2 = sprint2.startDate {
                        return date1 > date2
                    }
                    // Fallback sur l'ID si pas de dates
                    return sprint1.id > sprint2.id
                }
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

    // MARK: - Generate Sprint Review Summary with Claude
    func generateSprintReview(for sprint: Sprint) async {
        guard !claudeAPIKey.isEmpty else {
            await MainActor.run {
                errorMessage = "Claude API key not configured"
            }
            return
        }

        // Calculer les statistiques du sprint
        let totalIssues = issues.count
        let doneIssues = issues.filter { $0.status.lowercased().contains("done") || $0.status.lowercased().contains("terminé") || $0.status.lowercased().contains("closed") }
        let inProgressIssues = issues.filter { $0.status.lowercased().contains("progress") || $0.status.lowercased().contains("cours") }
        let todoIssues = issues.filter { !$0.status.lowercased().contains("done") && !$0.status.lowercased().contains("progress") && !$0.status.lowercased().contains("terminé") && !$0.status.lowercased().contains("cours") && !$0.status.lowercased().contains("closed") }

        // Grouper par type
        let issuesByType = Dictionary(grouping: issues) { $0.issueType }
        let doneByType = Dictionary(grouping: doneIssues) { $0.issueType }

        let issuesDescription = issues.map { "- [\($0.key)] \($0.summary) - Status: \($0.status)" }.joined(separator: "\n")

        let prompt = """
        Génère un résumé de Sprint Review en français pour ce sprint Jira:

        Sprint: \(sprint.name)
        Goal: \(sprint.goal ?? "Aucun objectif défini")

        Statistiques:
        - Total tickets: \(totalIssues)
        - Tickets Done: \(doneIssues.count) (\(totalIssues > 0 ? Int((Double(doneIssues.count) / Double(totalIssues)) * 100) : 0)%)
        - En cours: \(inProgressIssues.count)
        - À faire: \(todoIssues.count)

        Types de tickets:
        \(issuesByType.map { type, tickets in "- \(type): \(tickets.count) total, \(doneByType[type]?.count ?? 0) done" }.joined(separator: "\n"))

        Liste des tickets:
        \(issuesDescription)

        Génère un résumé structuré pour une sprint review avec:
        1. Vue d'ensemble (objectifs atteints, progression)
        2. Points positifs (ce qui a bien fonctionné)
        3. Points d'attention (ce qui reste à faire, blocages éventuels)
        4. Recommandations pour le prochain sprint
        """

        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(claudeAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        let body: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 1500,
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
                    id: "\(sprint.id)",
                    issueKey: "SPRINT-\(sprint.id)",
                    summary: text,
                    generatedAt: Date()
                )

                await MainActor.run {
                    self.summaries["SPRINT-\(sprint.id)"] = summary
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to generate sprint review: \(error.localizedDescription)"
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
