import Foundation
import Combine

class JiraManager: ObservableObject {
    @Published var issues: [JiraIssue] = []
    @Published var sprints: [Sprint] = []
    @Published var selectedSprint: Sprint?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var summaries: [String: IssueSummary] = [:]

    private var jiraBaseURL: String {
        UserDefaults.standard.string(forKey: "jiraBaseURL") ?? "https://jira.ets.mpi-internal.com"
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
        UserDefaults.standard.string(forKey: "projectKey") ?? "LBCMONSPE"
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Fetch Sprints
    func fetchSprints() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        // For Jira Server, we need to get the board ID first
        guard let boardId = await getBoardId() else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Could not find board for project"
            }
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
        request.addBasicAuth(username: jiraUsername, token: jiraToken)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
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
                self.errorMessage = "Failed to fetch sprints: \(error.localizedDescription)"
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
        request.addBasicAuth(username: jiraUsername, token: jiraToken)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }

            let searchResponse = try JSONDecoder().decode(JiraSearchResponse.self, from: data)

            await MainActor.run {
                self.issues = searchResponse.issues
                isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to fetch issues: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }

    // MARK: - Get Board ID
    private func getBoardId() async -> Int? {
        let urlString = "\(jiraBaseURL)/rest/agile/1.0/board"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "projectKeyOrId", value: projectKey)
        ]

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.addBasicAuth(username: jiraUsername, token: jiraToken)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let values = json?["values"] as? [[String: Any]]
            return values?.first?["id"] as? Int
        } catch {
            return nil
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
}
