import Foundation

// MARK: - Jira Issue
struct JiraIssue: Identifiable, Codable, Hashable {
    let id: String
    let key: String
    let fields: IssueFields

    var summary: String { fields.summary }
    var description: String? { fields.description }
    var status: String { fields.status.name }
    var assignee: String? { fields.assignee?.displayName }
    var priority: String? { fields.priority?.name }
    var issueType: String { fields.issuetype.name }
    var created: Date? {
        parseJiraDate(fields.created)
    }
    var updated: Date? {
        parseJiraDate(fields.updated)
    }
    var resolved: Date? {
        if let resDate = fields.resolutiondate {
            return parseJiraDate(resDate)
        }
        // Fallback: utiliser updated pour les tickets "Done"
        if status.lowercased().contains("done") || status.lowercased().contains("terminé") || status.lowercased().contains("closed") {
            return parseJiraDate(fields.updated)
        }
        return nil
    }
    var timeSpentSeconds: Int? { fields.timetracking?.timeSpentSeconds }
    var originalEstimateSeconds: Int? { fields.timetracking?.originalEstimateSeconds }

    private func parseJiraDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: dateString) {
            return date
        }

        // Fallback sans millisecondes
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }
}

struct IssueFields: Codable, Hashable {
    let summary: String
    let description: String?
    let status: IssueStatus
    let assignee: JiraUser?
    let priority: IssuePriority?
    let issuetype: IssueType
    let created: String?
    let updated: String?
    let resolutiondate: String?
    let sprint: Sprint?
    let timetracking: TimeTracking?

    enum CodingKeys: String, CodingKey {
        case summary, description, status, assignee, priority, issuetype, created, updated, resolutiondate, timetracking
        case sprint = "customfield_10020"
    }
}

struct TimeTracking: Codable, Hashable {
    let originalEstimateSeconds: Int?
    let remainingEstimateSeconds: Int?
    let timeSpentSeconds: Int?

    enum CodingKeys: String, CodingKey {
        case originalEstimateSeconds
        case remainingEstimateSeconds
        case timeSpentSeconds
    }
}

struct IssueStatus: Codable, Hashable {
    let name: String
}

struct JiraUser: Codable, Hashable {
    let displayName: String
    let emailAddress: String?
}

struct IssuePriority: Codable, Hashable {
    let name: String
}

struct IssueType: Codable, Hashable {
    let name: String
    let iconUrl: String?
}

// MARK: - Sprint
struct Sprint: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let state: String
    let startDate: String?
    let endDate: String?
    let goal: String?
}

// MARK: - Jira Response
struct JiraSearchResponse: Codable {
    let issues: [JiraIssue]
    let total: Int
}

struct JiraSprintResponse: Codable {
    let values: [Sprint]
}

// MARK: - AI Summary
struct IssueSummary: Identifiable, Hashable {
    let id: String
    let issueKey: String
    let summary: String
    let generatedAt: Date
}
