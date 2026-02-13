import SwiftUI

struct ContentView: View {
    @EnvironmentObject var jiraManager: JiraManager
    @State private var selectedIssue: JiraIssue?
    @State private var showingWelcome = true

    var body: some View {
        Group {
            if !jiraManager.isConfigured && showingWelcome {
                VStack(spacing: 20) {
                    Image(systemName: "gearshape.2")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)

                    Text("Configuration requise")
                        .font(.title)
                        .fontWeight(.semibold)

                    Text("Veuillez configurer votre Personal Access Token Jira dans les préférences")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if #available(macOS 14.0, *) {
                        SettingsLink {
                            HStack {
                                Image(systemName: "key.fill")
                                Text("Configurer le Token")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        Button(action: {
                            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                        }) {
                            HStack {
                                Image(systemName: "key.fill")
                                Text("Configurer le Token")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                NavigationSplitView {
                    // Sidebar - Sprint List
                    SprintListView(selectedSprint: $jiraManager.selectedSprint)
                } content: {
                    // Middle - Issue List
                    IssueListView(selectedIssue: $selectedIssue)
                } detail: {
                    // Detail - Issue Detail
                    if let issue = selectedIssue {
                        IssueDetailView(issue: issue)
                    } else {
                        Text("Sélectionnez un ticket")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationSplitViewStyle(.balanced)
                .task {
                    await jiraManager.fetchSprints()
                }
            }
        }
        .alert(
            "Erreur",
            isPresented: Binding(
                get: { jiraManager.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        jiraManager.errorMessage = nil
                    }
                }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(jiraManager.errorMessage ?? "Erreur inconnue")
        }
    }
}

// MARK: - Sprint List View
struct SprintListView: View {
    @EnvironmentObject var jiraManager: JiraManager
    @Binding var selectedSprint: Sprint?

    var body: some View {
        List(selection: $selectedSprint) {
            Section("Sprints") {
                ForEach(jiraManager.sprints) { sprint in
                    SprintRow(sprint: sprint)
                        .tag(sprint)
                }
            }
        }
        .navigationTitle("Sprints")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Task {
                        await jiraManager.fetchSprints()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(jiraManager.isLoading)
            }
        }
        .onChange(of: selectedSprint) { newValue in
            Task {
                await jiraManager.fetchIssues(for: newValue)
            }
        }
    }
}

struct SprintRow: View {
    let sprint: Sprint

    var statusColor: Color {
        switch sprint.state.lowercased() {
        case "active": return .green
        case "closed": return .gray
        case "future": return .blue
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(sprint.name)
                    .font(.headline)
                Spacer()
                Text(sprint.state.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(4)
            }

            if let goal = sprint.goal, !goal.isEmpty {
                Text(goal)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            if let startDate = sprint.startDate, let endDate = sprint.endDate {
                Text("\(formatDate(startDate)) - \(formatDate(endDate))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .short
        return displayFormatter.string(from: date)
    }
}

// MARK: - Issue List View
struct IssueListView: View {
    @EnvironmentObject var jiraManager: JiraManager
    @Binding var selectedIssue: JiraIssue?

    var body: some View {
        Group {
            if jiraManager.isLoading {
                ProgressView("Chargement...")
            } else if jiraManager.issues.isEmpty {
                Text("Aucun ticket trouvé")
                    .foregroundColor(.secondary)
            } else {
                List(jiraManager.issues, selection: $selectedIssue) { issue in
                    IssueRow(issue: issue)
                        .tag(issue)
                }
            }
        }
        .navigationTitle("Tickets (\(jiraManager.issues.count))")
        .toolbar {
            if let error = jiraManager.errorMessage {
                ToolbarItem(placement: .status) {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
    }
}

struct IssueRow: View {
    let issue: JiraIssue

    var priorityColor: Color {
        switch issue.priority?.lowercased() {
        case "highest", "high": return .red
        case "medium": return .orange
        case "low", "lowest": return .blue
        default: return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(issue.key)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(4)

                Text(issue.issueType)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                if let priority = issue.priority {
                    Circle()
                        .fill(priorityColor)
                        .frame(width: 8, height: 8)
                    Text(priority)
                        .font(.caption2)
                        .foregroundColor(priorityColor)
                }
            }

            Text(issue.summary)
                .font(.body)
                .lineLimit(2)

            HStack {
                Label(issue.status, systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let assignee = issue.assignee {
                    Label(assignee, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Issue Detail View
struct IssueDetailView: View {
    @EnvironmentObject var jiraManager: JiraManager
    let issue: JiraIssue
    @State private var isGeneratingSummary = false

    var summary: IssueSummary? {
        jiraManager.summaries[issue.key]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(issue.key)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            if let url = URL(string: "\(jiraManager.jiraBaseURL)/browse/\(issue.key)") {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            Label("Ouvrir dans Jira", systemImage: "arrow.up.right.square")
                        }
                    }

                    Text(issue.summary)
                        .font(.title3)
                }

                Divider()

                // AI Summary
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Résumé IA", systemImage: "sparkles")
                            .font(.headline)
                        Spacer()

                        if isGeneratingSummary {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Button(action: {
                                Task {
                                    isGeneratingSummary = true
                                    await jiraManager.generateSummary(for: issue)
                                    isGeneratingSummary = false
                                }
                            }) {
                                Label(summary == nil ? "Générer" : "Régénérer", systemImage: "wand.and.stars")
                            }
                        }
                    }

                    if let summary = summary {
                        Text(summary.summary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    } else {
                        Text("Cliquez sur 'Générer' pour créer un résumé avec Claude")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                Divider()

                // Details
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                    GridRow {
                        Text("Status:")
                            .fontWeight(.semibold)
                        Text(issue.status)
                    }

                    GridRow {
                        Text("Type:")
                            .fontWeight(.semibold)
                        Text(issue.issueType)
                    }

                    if let priority = issue.priority {
                        GridRow {
                            Text("Priorité:")
                                .fontWeight(.semibold)
                            Text(priority)
                        }
                    }

                    if let assignee = issue.assignee {
                        GridRow {
                            Text("Assigné à:")
                                .fontWeight(.semibold)
                            Text(assignee)
                        }
                    }

                    if let created = issue.created {
                        GridRow {
                            Text("Créé le:")
                                .fontWeight(.semibold)
                            Text(created, style: .date)
                        }
                    }
                }

                if let description = issue.description, !description.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)

                        Text(description)
                            .textSelection(.enabled)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    ContentView()
        .environmentObject(JiraManager())
}
