import SwiftUI

struct ContentView: View {
    @EnvironmentObject var jiraManager: JiraManager
    @State private var selectedIssue: JiraIssue?
    @State private var showingWelcome = true
    @State private var showSprintReview = true

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
                    IssueListView(selectedIssue: $selectedIssue, showSprintReview: $showSprintReview)
                } detail: {
                    // Detail - Sprint Review or Issue Detail
                    if showSprintReview, let sprint = jiraManager.selectedSprint {
                        SprintReviewView(sprint: sprint)
                    } else if let issue = selectedIssue {
                        IssueDetailView(issue: issue)
                    } else {
                        Text("Sélectionnez un ticket ou affichez le résumé du sprint")
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
                .buttonStyle(.borderless)
                .controlSize(.large)
                .tint(.accentColor)
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
        // Essayer plusieurs formats de parsing
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "fr_FR")
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }

        // Essayer sans les millisecondes
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.locale = Locale(identifier: "fr_FR")
            displayFormatter.dateFormat = "dd/MM/yyyy"
            return displayFormatter.string(from: date)
        }

        // Si rien ne fonctionne, retourner la string brute
        return dateString
    }
}

// MARK: - Issue List View
struct IssueListView: View {
    @EnvironmentObject var jiraManager: JiraManager
    @Binding var selectedIssue: JiraIssue?
    @Binding var showSprintReview: Bool

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
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    showSprintReview.toggle()
                    if showSprintReview {
                        selectedIssue = nil
                    }
                }) {
                    Label(showSprintReview ? "Tickets" : "Sprint Review",
                          systemImage: showSprintReview ? "list.bullet" : "chart.bar.doc.horizontal")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.accentColor)
            }

            if let error = jiraManager.errorMessage {
                ToolbarItem(placement: .status) {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
        }
        .onChange(of: selectedIssue) { newValue in
            if newValue != nil {
                showSprintReview = false
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
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .tint(.accentColor)
                    }

                    Text(issue.summary)
                        .font(.title3)
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

// MARK: - Sprint Review View
struct SprintReviewView: View {
    @EnvironmentObject var jiraManager: JiraManager
    let sprint: Sprint
    @State private var isGenerating = false
    @State private var displayedText = ""
    @State private var animationTask: Task<Void, Never>?

    var sprintSummaryKey: String {
        "SPRINT-\(sprint.id)"
    }

    var summary: IssueSummary? {
        jiraManager.summaries[sprintSummaryKey]
    }

    var stats: (total: Int, done: Int, inProgress: Int, todo: Int, byType: [String: Int]) {
        let total = jiraManager.issues.count
        let done = jiraManager.issues.filter { $0.status.lowercased().contains("done") || $0.status.lowercased().contains("terminé") || $0.status.lowercased().contains("closed") }.count
        let inProgress = jiraManager.issues.filter { $0.status.lowercased().contains("progress") || $0.status.lowercased().contains("cours") }.count
        let todo = total - done - inProgress

        let byType = Dictionary(grouping: jiraManager.issues) { $0.issueType }
            .mapValues { $0.count }

        return (total, done, inProgress, todo, byType)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("Sprint Review")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(sprint.name)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let goal = sprint.goal, !goal.isEmpty {
                        Text("Objectif: \(goal)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                Divider()

                // Statistiques
                VStack(alignment: .leading, spacing: 16) {
                    Text("Statistiques")
                        .font(.headline)

                    HStack(spacing: 20) {
                        StatCard(title: "Total", value: "\(stats.total)", color: .blue)
                        StatCard(title: "Done", value: "\(stats.done)", color: .green)
                        StatCard(title: "En cours", value: "\(stats.inProgress)", color: .orange)
                        StatCard(title: "À faire", value: "\(stats.todo)", color: .gray)
                    }

                    // Progression
                    let progress = stats.total > 0 ? Double(stats.done) / Double(stats.total) : 0
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progression")
                                .font(.subheadline)
                            Spacer()
                            Text("\(Int(progress * 100))%")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        ProgressView(value: progress)
                            .tint(.green)
                    }

                    // Par type
                    if !stats.byType.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Par type")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            ForEach(stats.byType.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
                                HStack {
                                    Text(type)
                                    Spacer()
                                    Text("\(count)")
                                        .fontWeight(.medium)
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Divider()

                // Résumé du Sprint
                if stats.total > 0 {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Résumé du Sprint", systemImage: "doc.text.fill")
                                .font(.headline)
                            Spacer()

                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Button(action: {
                                    Task {
                                        isGenerating = true
                                        await jiraManager.generateSprintReview(for: sprint)
                                        isGenerating = false
                                    }
                                }) {
                                    Label(summary == nil ? "Générer le Résumé" : "Régénérer",
                                          systemImage: "arrow.clockwise")
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .tint(.accentColor)
                            }
                        }

                        if let summary = summary {
                            ScrollView {
                                Text(displayedText)
                                    .font(.body)
                                    .lineSpacing(3)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .textSelection(.enabled)
                            }
                            .frame(maxHeight: 400)
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(8)
                            .onAppear {
                                startTypingAnimation(fullText: summary.summary)
                            }
                            .onChange(of: summary.summary) { newText in
                                startTypingAnimation(fullText: newText)
                            }
                        } else {
                            Text("Cliquez sur 'Générer le Résumé' pour créer un résumé structuré du sprint")
                                .foregroundColor(.secondary)
                                .italic()
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Résumé du Sprint", systemImage: "doc.text.fill")
                                .font(.headline)
                            Spacer()
                        }

                        Text("Aucun ticket dans ce sprint. Ajoutez des tickets pour générer un résumé.")
                            .foregroundColor(.secondary)
                            .italic()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onDisappear {
            animationTask?.cancel()
        }
    }

    private func startTypingAnimation(fullText: String) {
        // Annuler l'animation en cours si elle existe
        animationTask?.cancel()

        // Réinitialiser le texte affiché
        displayedText = ""

        // Créer une nouvelle tâche d'animation
        animationTask = Task {
            let lines = fullText.split(separator: "\n", omittingEmptySubsequences: false)

            for line in lines {
                // Vérifier si la tâche a été annulée
                if Task.isCancelled { return }

                // Ajouter la ligne avec un petit délai
                await MainActor.run {
                    if !displayedText.isEmpty {
                        displayedText += "\n"
                    }
                    displayedText += String(line)
                }

                // Délai progressif: plus rapide au début, plus lent pour les titres/sections
                let delay: UInt64
                if line.hasPrefix("📊") || line.hasPrefix("✅") || line.hasPrefix("⚠️") || line.hasPrefix("📋") || line.hasPrefix("💡") {
                    // Titres avec emojis: pause plus longue
                    delay = 80_000_000 // 0.08 secondes
                } else if line.isEmpty {
                    // Lignes vides: pause très courte
                    delay = 10_000_000 // 0.01 secondes
                } else {
                    // Lignes normales
                    delay = 30_000_000 // 0.03 secondes
                }

                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
        .environmentObject(JiraManager())
}
