//
//  GenerateSprintReviewUseCase.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Use case to generate a sprint summary
final class GenerateSprintReviewUseCase {
    init() {}

    /// Generates a complete sprint summary
    func execute(sprint: Sprint, issues: [Issue]) -> SprintReview {
        // 1. Calculate basic statistics
        let totalIssues = issues.count
        let doneIssues = issues.filter { $0.isCompleted }
        let inProgressIssues = issues.filter { $0.isInProgress }
        let todoIssues = issues.filter { $0.isTodo }

        let completionPercentage = totalIssues > 0 ?
            Int((Double(doneIssues.count) / Double(totalIssues)) * 100) : 0

        // 2. Group by type
        let issuesByType = Dictionary(grouping: issues) { $0.issueType.name }
            .mapValues { $0.count }
        let doneByType = Dictionary(grouping: doneIssues) { $0.issueType.name }
            .mapValues { $0.count }

        // 3. Calculate time metrics
        let timeMetrics = calculateTimeMetrics(issues: issues, doneIssues: doneIssues)

        // 4. Calculate cycle time metrics
        let cycleTimeMetrics = calculateCycleTimeMetrics(doneIssues: doneIssues)

        // 5. Generate summary text
        let summaryText = generateSummaryText(
            sprint: sprint,
            totalIssues: totalIssues,
            doneIssues: doneIssues,
            inProgressIssues: inProgressIssues,
            todoIssues: todoIssues,
            completionPercentage: completionPercentage,
            issuesByType: issuesByType,
            doneByType: doneByType,
            timeMetrics: timeMetrics,
            cycleTimeMetrics: cycleTimeMetrics
        )

        return SprintReview(
            sprintId: sprint.id,
            sprintName: sprint.name,
            totalIssues: totalIssues,
            doneIssues: doneIssues.count,
            inProgressIssues: inProgressIssues.count,
            todoIssues: todoIssues.count,
            completionPercentage: completionPercentage,
            issuesByType: issuesByType,
            doneByType: doneByType,
            timeMetrics: timeMetrics,
            cycleTimeMetrics: cycleTimeMetrics,
            summaryText: summaryText
        )
    }

    // MARK: - Private Helpers

    private func calculateTimeMetrics(
        issues: [Issue],
        doneIssues: [Issue]
    ) -> SprintReview.TimeMetrics? {
        let totalTimeSpentSeconds = issues.compactMap { $0.timeTracking?.timeSpentSeconds }.reduce(0, +)
        let totalEstimateSeconds = issues.compactMap { $0.timeTracking?.originalEstimateSeconds }.reduce(0, +)
        let doneTimeSpentSeconds = doneIssues.compactMap { $0.timeTracking?.timeSpentSeconds }.reduce(0, +)

        guard totalTimeSpentSeconds > 0 else { return nil }

        let totalTimeSpentHours = Double(totalTimeSpentSeconds) / 3600.0
        let totalEstimateHours = Double(totalEstimateSeconds) / 3600.0
        let doneTimeSpentHours = Double(doneTimeSpentSeconds) / 3600.0
        let averageTimePerTicketHours = doneIssues.count > 0 ?
            doneTimeSpentHours / Double(doneIssues.count) : 0
        let accuracyPercentage = totalEstimateSeconds > 0 ?
            Int((Double(totalTimeSpentSeconds) / Double(totalEstimateSeconds)) * 100) : 0

        return SprintReview.TimeMetrics(
            totalTimeSpentHours: totalTimeSpentHours,
            totalEstimateHours: totalEstimateHours,
            doneTimeSpentHours: doneTimeSpentHours,
            averageTimePerTicketHours: averageTimePerTicketHours,
            accuracyPercentage: accuracyPercentage
        )
    }

    private func calculateCycleTimeMetrics(doneIssues: [Issue]) -> SprintReview.CycleTimeMetrics? {
        let doneTicketsWithDates = doneIssues.filter {
            $0.created != nil && $0.resolved != nil
        }

        guard !doneTicketsWithDates.isEmpty else { return nil }

        var totalCycleDays = 0.0
        for ticket in doneTicketsWithDates {
            if let created = ticket.created, let resolved = ticket.resolved {
                let cycleDays = resolved.timeIntervalSince(created) / 86400.0
                totalCycleDays += cycleDays
            }
        }

        let avgCycleDays = totalCycleDays / Double(doneTicketsWithDates.count)

        // Identify the longest ticket
        let sortedByDuration = doneTicketsWithDates.sorted {
            guard let created1 = $0.created, let resolved1 = $0.resolved,
                  let created2 = $1.created, let resolved2 = $1.resolved else {
                return false
            }
            return resolved1.timeIntervalSince(created1) > resolved2.timeIntervalSince(created2)
        }

        guard let longest = sortedByDuration.first,
              let created = longest.created,
              let resolved = longest.resolved else {
            return nil
        }

        let longestDays = resolved.timeIntervalSince(created) / 86400.0

        return SprintReview.CycleTimeMetrics(
            averageCycleDays: avgCycleDays,
            analyzedTicketsCount: doneTicketsWithDates.count,
            longestTicketKey: longest.key,
            longestTicketDays: longestDays
        )
    }

    private func generateSummaryText(
        sprint: Sprint,
        totalIssues: Int,
        doneIssues: [Issue],
        inProgressIssues: [Issue],
        todoIssues: [Issue],
        completionPercentage: Int,
        issuesByType: [String: Int],
        doneByType: [String: Int],
        timeMetrics: SprintReview.TimeMetrics?,
        cycleTimeMetrics: SprintReview.CycleTimeMetrics?
    ) -> String {
        var text = "Sprint Review - \(sprint.name)\n\n"

        // Overview
        text += "📊 OVERVIEW\n"
        if let goal = sprint.goal, !goal.isEmpty {
            text += "Goal: \(goal)\n"
        }
        text += "This sprint had \(totalIssues) tickets in total, with a completion rate of \(completionPercentage)%.\n"

        // Time metrics
        if let metrics = timeMetrics {
            text += "\n⏱️ TIME & EFFORT\n"
            text += "  • Total time spent: \(String(format: "%.1f", metrics.totalTimeSpentHours))h (\(String(format: "%.1f", metrics.totalTimeSpentDays)) days)\n"

            if metrics.totalEstimateHours > 0 {
                text += "  • Estimated time: \(String(format: "%.1f", metrics.totalEstimateHours))h\n"

                if metrics.isOverEstimated {
                    text += "  • Overrun: +\(metrics.accuracyPercentage - 100)% of estimated time\n"
                } else if metrics.isUnderEstimated {
                    text += "  • Underestimation avoided: \(100 - metrics.accuracyPercentage)% time saved\n"
                } else {
                    text += "  • Accurate estimate: \(metrics.accuracyPercentage)% of planned time\n"
                }
            }

            if doneIssues.count > 0 {
                text += "  • Average time per completed ticket: \(String(format: "%.1f", metrics.averageTimePerTicketHours))h\n"
            }
        } else if let cycleMetrics = cycleTimeMetrics {
            text += "\n⏱️ CYCLE TIME\n"
            text += "  • Average cycle time: \(String(format: "%.1f", cycleMetrics.averageCycleDays)) days\n"
            text += "  • \(cycleMetrics.analyzedTicketsCount) completed tickets analyzed\n"
            text += "  • Longest ticket: \(cycleMetrics.longestTicketKey) (\(String(format: "%.1f", cycleMetrics.longestTicketDays)) days)\n"
        }

        // Positive points
        text += "\n✅ POSITIVE POINTS\n"
        if completionPercentage >= 80 {
            text += "  • Excellent completion rate (\(completionPercentage)%)\n"
            text += "    Sprint goal largely achieved\n"
        } else if completionPercentage >= 60 {
            text += "  • Good completion rate (\(completionPercentage)%)\n"
            text += "    Most objectives were achieved\n"
        } else if completionPercentage >= 40 {
            text += "  • Fair progress with \(completionPercentage)% completion\n"
        }

        if doneIssues.count > 0 {
            text += "  • \(doneIssues.count) tickets completed and delivered\n"
        }

        let sortedTypes = issuesByType.sorted { $0.value > $1.value }
        if !sortedTypes.isEmpty {
            text += "  • Work diversity:\n"
            text += "    \(sortedTypes.map { "\($0.value) \($0.key)" }.joined(separator: ", "))\n"
        }

        // Points of attention
        text += "\n⚠️ POINTS OF ATTENTION\n"
        if inProgressIssues.count > 0 {
            text += "  • \(inProgressIssues.count) tickets still in progress\n"
            text += "    Require special attention\n"
        }
        if todoIssues.count > 0 {
            text += "  • \(todoIssues.count) tickets were not started\n"
        }
        if completionPercentage < 60 {
            text += "  • Completion rate (\(completionPercentage)%)\n"
            text += "    Suggests adjustments in estimation\n"
            text += "    or team capacity\n"
        }

        // Completed tickets by type
        if !doneByType.isEmpty {
            text += "\n📋 COMPLETED TICKETS BY TYPE\n"
            for (type, count) in doneByType.sorted(by: { $0.value > $1.value }) {
                text += "  • \(type): \(count) ticket\(count > 1 ? "s" : "")\n"
            }
        }

        // Recommendations
        text += "\n💡 RECOMMENDATIONS\n"
        if completionPercentage < 60 {
            text += "  • Review team capacity\n"
            text += "    Adjust the number of planned tickets\n"
        }
        if inProgressIssues.count > totalIssues / 3 {
            text += "  • Limit the number of tickets in progress\n"
            text += "    simultaneously to improve flow\n"
        }
        if todoIssues.count > 0 {
            text += "  • Prioritize unstarted tickets\n"
            text += "    or move them to the next sprint\n"
        }
        text += "  • Continue retrospectives to identify\n"
        text += "    possible improvements"

        return text
    }
}
