//
//  GenerateSprintReviewUseCaseTests.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

/// Tests for GenerateSprintReviewUseCase
final class GenerateSprintReviewUseCaseTests: XCTestCase {
    var sut: GenerateSprintReviewUseCase!

    override func setUp() {
        super.setUp()
        sut = GenerateSprintReviewUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testExecute_ShouldCalculateCorrectStats() {
        // Given
        let sprint = Sprint(id: 1, name: "Sprint Test", state: .active)
        let issues = [
            createIssue(status: "Done"),
            createIssue(status: "Done"),
            createIssue(status: "In Progress"),
            createIssue(status: "To Do")
        ]

        // When
        let result = sut.execute(sprint: sprint, issues: issues)

        // Then
        XCTAssertEqual(result.totalIssues, 4)
        XCTAssertEqual(result.doneIssues, 2)
        XCTAssertEqual(result.inProgressIssues, 1)
        XCTAssertEqual(result.todoIssues, 1)
        XCTAssertEqual(result.completionPercentage, 50)
    }

    func testExecute_ShouldGenerateSummaryText() {
        // Given
        let sprint = Sprint(id: 1, name: "Sprint Test", state: .active, goal: "Test goal")
        let issues = [createIssue(status: "Done")]

        // When
        let result = sut.execute(sprint: sprint, issues: issues)

        // Then
        XCTAssertFalse(result.summaryText.isEmpty)
        XCTAssertTrue(result.summaryText.contains("Sprint Review"))
        XCTAssertTrue(result.summaryText.contains("Sprint Test"))
        XCTAssertTrue(result.summaryText.contains("Test goal"))
    }

    func testExecute_ShouldGroupIssuesByType() {
        // Given
        let sprint = Sprint(id: 1, name: "Sprint Test", state: .active)
        let issues = [
            createIssue(status: "Done", type: "Story"),
            createIssue(status: "Done", type: "Story"),
            createIssue(status: "Done", type: "Bug")
        ]

        // When
        let result = sut.execute(sprint: sprint, issues: issues)

        // Then
        XCTAssertEqual(result.issuesByType["Story"], 2)
        XCTAssertEqual(result.issuesByType["Bug"], 1)
        XCTAssertEqual(result.doneByType["Story"], 2)
        XCTAssertEqual(result.doneByType["Bug"], 1)
    }

    func testExecute_ShouldCalculateTimeMetrics_WhenTimeTrackingAvailable() {
        // Given
        let sprint = Sprint(id: 1, name: "Sprint Test", state: .active)
        let issues = [
            createIssue(
                status: "Done",
                timeSpent: 3600,  // 1 hour
                timeEstimate: 7200 // 2 hours
            ),
            createIssue(
                status: "Done",
                timeSpent: 7200,  // 2 hours
                timeEstimate: 3600 // 1 hour
            )
        ]

        // When
        let result = sut.execute(sprint: sprint, issues: issues)

        // Then
        XCTAssertNotNil(result.timeMetrics)
        XCTAssertEqual(result.timeMetrics?.totalTimeSpentHours, 3.0, accuracy: 0.1)
        XCTAssertEqual(result.timeMetrics?.totalEstimateHours, 3.0, accuracy: 0.1)
    }

    func testExecute_ShouldCalculateCycleTimeMetrics_WhenDatesAvailable() {
        // Given
        let sprint = Sprint(id: 1, name: "Sprint Test", state: .active)
        let created = Date().addingTimeInterval(-86400 * 5) // 5 days before
        let resolved = Date()
        let issues = [
            createIssue(status: "Done", created: created, resolved: resolved)
        ]

        // When
        let result = sut.execute(sprint: sprint, issues: issues)

        // Then
        XCTAssertNotNil(result.cycleTimeMetrics)
        XCTAssertEqual(result.cycleTimeMetrics?.averageCycleDays, 5.0, accuracy: 0.1)
        XCTAssertEqual(result.cycleTimeMetrics?.analyzedTicketsCount, 1)
    }

    // MARK: - Helpers

    private func createIssue(
        status: String,
        type: String = "Story",
        timeSpent: Int? = nil,
        timeEstimate: Int? = nil,
        created: Date? = nil,
        resolved: Date? = nil
    ) -> Issue {
        let timeTracking = (timeSpent != nil || timeEstimate != nil) ?
            TimeTracking(
                originalEstimateSeconds: timeEstimate,
                timeSpentSeconds: timeSpent
            ) : nil

        return Issue(
            id: UUID().uuidString,
            key: "TEST-\(Int.random(in: 1...1000))",
            summary: "Test issue",
            status: IssueStatus(name: status),
            issueType: IssueType(name: type),
            created: created,
            resolved: resolved,
            timeTracking: timeTracking
        )
    }
}
