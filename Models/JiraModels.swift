import Foundation

// MARK: - Jira Issue
struct JiraIssue: Identifiable, Codable {
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
        ISO8601DateFormatter().date(from: fields.created ?? "")
    }
}

struct IssueFields: Codable {
    let summary: String
    let description: String?
    let status: IssueStatus
    let assignee: JiraUser?
    let priority: IssuePriority?
    let issuetype: IssueType
    let created: String?
    let sprint: Sprint?

    enum CodingKeys: String, CodingKey {
        case summary, description, status, assignee, priority, issuetype, created
        case sprint = "customfield_10020"
    }
}

struct IssueStatus: Codable {
    let name: String
}

struct JiraUser: Codable {
    let displayName: String
    let emailAddress: String?
}

struct IssuePriority: Codable {
    let name: String
}

struct IssueType: Codable {
    let name: String
    let iconUrl: String?
}

// MARK: - Sprint
struct Sprint: Codable, Identifiable {
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
struct IssueSummary: Identifiable {
    let id: String
    let issueKey: String
    let summary: String
    let generatedAt: Date
}
