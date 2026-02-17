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

                // Status Flow Analysis
                statusFlowSection

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

            // Blocked Issues Metrics
            if let metrics = viewModel.sprintReview?.blockedIssuesMetrics {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Blocked Issues", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)

                    HStack(spacing: 20) {
                        StatCard(
                            title: "Blocked",
                            value: "\(metrics.blockedCount)",
                            subtitle: "\(metrics.flaggedCount) flagged, \(metrics.stagnantCount) stagnant",
                            color: .red
                        )

                        if metrics.blockedCount > 0 {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Average blocked duration:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.1f", metrics.averageBlockedDays)) days")
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                        }
                    }

                    if let bottleneck = metrics.bottleneckStatus {
                        HStack {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .foregroundColor(.orange)
                            Text("Bottleneck detected in '\(bottleneck)' status")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        .padding(8)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.05))
                .cornerRadius(8)
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

    // MARK: - Status Flow Section

    private var statusFlowSection: some View {
        Group {
            if let flowMetrics = viewModel.sprintReview?.statusFlowMetrics, !flowMetrics.statusAverageDays.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Label("Status Flow Analysis", systemImage: "arrow.right.circle.fill")
                            .font(.headline)
                        Spacer()
                        Text("\(flowMetrics.totalTicketsAnalyzed) tickets analyzed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("Time spent in work statuses during this sprint:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Tickets that took too long (stuck)
                    let stuckTickets = flowMetrics.ticketDetails.filter { $0.isStuck }
                    if !stuckTickets.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("Tickets stuck (>3 days in a status)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                            }

                            ForEach(stuckTickets.sorted(by: { $0.totalWorkDays > $1.totalWorkDays })) { ticket in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(ticket.key)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.red.opacity(0.2))
                                            .cornerRadius(4)

                                        Text(ticket.summary)
                                            .font(.caption)
                                            .lineLimit(1)

                                        Spacer()

                                        Text(ticket.currentStatus)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }

                                    HStack(spacing: 12) {
                                        if let time = ticket.timeInProgress, time > 0 {
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(time > 3 ? Color.red : Color.green)
                                                    .frame(width: 6, height: 6)
                                                Text("In Progress: \(String(format: "%.1f", time))d")
                                                    .font(.caption2)
                                                    .foregroundColor(time > 3 ? .red : .primary)
                                            }
                                        }

                                        if let time = ticket.timeInReview, time > 0 {
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(time > 3 ? Color.red : Color.green)
                                                    .frame(width: 6, height: 6)
                                                Text("Review: \(String(format: "%.1f", time))d")
                                                    .font(.caption2)
                                                    .foregroundColor(time > 3 ? .red : .primary)
                                            }
                                        }

                                        if let time = ticket.timeInTest, time > 0 {
                                            HStack(spacing: 4) {
                                                Circle()
                                                    .fill(time > 3 ? Color.red : Color.green)
                                                    .frame(width: 6, height: 6)
                                                Text("Test: \(String(format: "%.1f", time))d")
                                                    .font(.caption2)
                                                    .foregroundColor(time > 3 ? .red : .primary)
                                            }
                                        }
                                    }
                                    .padding(.leading, 8)
                                }
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(Color.red.opacity(0.05))
                                .cornerRadius(6)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }

                    Divider()

                    // Average metrics
                    Text("Average time per status:")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    VStack(alignment: .leading, spacing: 12) {
                        // Sort by average days descending
                        ForEach(flowMetrics.statusAverageDays.sorted(by: { $0.value > $1.value }), id: \.key) { status, avgDays in
                            let ticketCount = flowMetrics.statusTicketCount[status] ?? 0

                            HStack(alignment: .top, spacing: 12) {
                                // Status name
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(status)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("\(ticketCount) ticket\(ticketCount > 1 ? "s" : "")")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .frame(width: 120, alignment: .leading)

                                // Progress bar
                                GeometryReader { geometry in
                                    let maxDays = flowMetrics.statusAverageDays.values.max() ?? 1
                                    let widthRatio = avgDays / maxDays
                                    let barWidth = geometry.size.width * widthRatio

                                    ZStack(alignment: .leading) {
                                        // Background
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 24)

                                        // Foreground
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(colorForDays(avgDays))
                                            .frame(width: max(barWidth, 40), height: 24)

                                        // Text
                                        Text(String(format: "%.1f days", avgDays))
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                            .padding(.leading, 8)
                                    }
                                }
                                .frame(height: 24)
                            }
                        }
                    }

                    Divider()

                    // Insights
                    VStack(alignment: .leading, spacing: 8) {
                        if let slowest = flowMetrics.statusAverageDays.max(by: { $0.value < $1.value }) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Slowest: \(slowest.key) (\(String(format: "%.1f", slowest.value)) days avg)")
                                    .font(.caption)
                            }
                        }

                        if let fastest = flowMetrics.statusAverageDays.min(by: { $0.value < $1.value }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Fastest: \(fastest.key) (\(String(format: "%.1f", fastest.value)) days avg)")
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }

    // Helper to color bars based on days
    private func colorForDays(_ days: Double) -> Color {
        if days > 7 {
            return .red
        } else if days > 3 {
            return .orange
        } else {
            return .green
        }
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
