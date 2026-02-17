//
//  SprintReviewView.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View to display Sprint Review with statistics and summary
struct SprintReviewView: View {
    @ObservedObject var viewModel: SprintReviewViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection

                Divider()

                // Statistiques
                statisticsSection

                Divider()

                // Résumé du Sprint
                summarySection
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onDisappear {
            viewModel.cancelAnimation()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "chart.bar.doc.horizontal.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                VStack(alignment: .leading) {
                    Text("Sprint Review")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(viewModel.sprint.name)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }

            if let goal = viewModel.sprint.goal, !goal.isEmpty {
                Text("Goal: \(goal)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.headline)

            HStack(spacing: 20) {
                StatCard(title: "Total", value: "\(viewModel.stats.total)", color: .blue)
                StatCard(title: "Done", value: "\(viewModel.stats.done)", color: .green)
                StatCard(title: "In Progress", value: "\(viewModel.stats.inProgress)", color: .orange)
                StatCard(title: "To Do", value: "\(viewModel.stats.todo)", color: .gray)
            }

            // Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                    Spacer()
                    Text("\(viewModel.stats.progressPercentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                ProgressView(value: viewModel.stats.progress)
                    .tint(.green)
            }

            // By type
            if !viewModel.stats.byType.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("By Type")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    ForEach(viewModel.stats.byType.sorted(by: { $0.value > $1.value }), id: \.key) { type, count in
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
    }

    // MARK: - Summary Section

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Sprint Summary", systemImage: "doc.text.fill")
                    .font(.headline)
                Spacer()

                if viewModel.isGenerating {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Button(action: {
                        Task {
                            await viewModel.generateReview()
                        }
                    }) {
                        Label(
                            viewModel.sprintReview == nil ? "Generate Summary" : "Regenerate",
                            systemImage: "arrow.clockwise"
                        )
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.accentColor)
                }
            }

            if let _ = viewModel.sprintReview {
                ScrollView {
                    Text(viewModel.displayedText)
                        .font(.body)
                        .lineSpacing(3)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
                .frame(maxHeight: 400)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            } else if viewModel.stats.total > 0 {
                Text("Click 'Generate Summary' to create a structured sprint summary")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("No tickets in this sprint. Add tickets to generate a summary.")
                    .foregroundColor(.secondary)
                    .italic()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    let sprint = Sprint(
        id: 1,
        name: "Sprint 25",
        state: .active,
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 14),
        goal: "Implement clean architecture"
    )

    let issues = [
        Issue(
            id: "1",
            key: "PROJ-1",
            summary: "Test issue 1",
            status: IssueStatus(name: "Done"),
            issueType: IssueType(name: "Story")
        ),
        Issue(
            id: "2",
            key: "PROJ-2",
            summary: "Test issue 2",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Bug")
        )
    ]

    let viewModel = DIContainer.shared.makeSprintReviewViewModel(sprint: sprint, issues: issues)

    return SprintReviewView(viewModel: viewModel)
}
