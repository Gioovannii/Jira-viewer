//
//  IssueTests.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import JiraViewer

final class IssueTests: XCTestCase {

    // MARK: - Tests for isCompleted

    func testIsCompleted_ShouldReturnTrue_WhenStatusContainsDone() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "Done"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isCompleted

        // Then
        XCTAssertTrue(result)
    }

    func testIsCompleted_ShouldReturnTrue_WhenStatusContainsClosed() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "Closed"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isCompleted

        // Then
        XCTAssertTrue(result)
    }

    func testIsCompleted_ShouldReturnFalse_WhenStatusIsInProgress() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isCompleted

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Tests for isInProgress

    func testIsInProgress_ShouldReturnTrue_WhenStatusContainsProgress() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isInProgress

        // Then
        XCTAssertTrue(result)
    }

    func testIsInProgress_ShouldReturnTrue_WhenStatusContainsCours() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "En cours"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isInProgress

        // Then
        XCTAssertTrue(result)
    }

    func testIsInProgress_ShouldReturnFalse_WhenStatusIsToDo() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "To Do"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isInProgress

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Tests for cycleTimeDays

    func testCycleTimeDays_ShouldReturnCorrectDays_WhenCreatedAndResolvedDatesExist() {
        // Given
        let created = Date(timeIntervalSince1970: 0) // Jan 1, 1970
        let resolved = Date(timeIntervalSince1970: 86400 * 5) // 5 days later

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "Done"),
            issueType: IssueType(name: "Story"),
            created: created,
            resolved: resolved
        )

        // When
        let result = issue.cycleTimeDays

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 5.0, accuracy: 0.01)
    }

    func testCycleTimeDays_ShouldReturnNil_WhenCreatedDateMissing() {
        // Given
        let resolved = Date()

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "Done"),
            issueType: IssueType(name: "Story"),
            created: nil,
            resolved: resolved
        )

        // When
        let result = issue.cycleTimeDays

        // Then
        XCTAssertNil(result)
    }

    func testCycleTimeDays_ShouldReturnNil_WhenResolvedDateMissing() {
        // Given
        let created = Date()

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            created: created,
            resolved: nil
        )

        // When
        let result = issue.cycleTimeDays

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Tests for daysInCurrentStatus

    func testDaysInCurrentStatus_ShouldReturnDaysFromHistory_WhenHistoryAvailable() {
        // Given
        let transitionDate = Date(timeIntervalSinceNow: -86400 * 5) // 5 days ago
        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: transitionDate,
                author: "Test User"
            )
        ]
        let history = IssueHistory(transitions: transitions)

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            history: history
        )

        // When
        let result = issue.daysInCurrentStatus

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 5.0, accuracy: 0.1)
    }

    func testDaysInCurrentStatus_ShouldUseFallback_WhenHistoryEmpty() {
        // Given
        let updated = Date(timeIntervalSinceNow: -86400 * 3) // 3 days ago

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            updated: updated,
            history: IssueHistory(transitions: [])
        )

        // When
        let result = issue.daysInCurrentStatus

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 3.0, accuracy: 0.1)
    }

    func testDaysInCurrentStatus_ShouldReturnNil_WhenNoHistoryAndNoUpdatedDate() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            updated: nil
        )

        // When
        let result = issue.daysInCurrentStatus

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Tests for isBlocked

    func testIsBlocked_ShouldReturnTrue_WhenIssueIsFlagged() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            isFlagged: true
        )

        // When
        let result = issue.isBlocked

        // Then
        XCTAssertTrue(result)
    }

    func testIsBlocked_ShouldReturnFalse_WhenIssueIsCompletedAndStagnant() {
        // Given
        let updated = Date(timeIntervalSinceNow: -86400 * 10) // 10 days ago

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "Done"),
            issueType: IssueType(name: "Story"),
            updated: updated
        )

        // When
        let result = issue.isBlocked

        // Then
        XCTAssertFalse(result, "Done issues should not be marked as blocked even if stagnant")
    }

    func testIsBlocked_ShouldReturnTrue_WhenStagnantForMoreThan3Days() {
        // Given
        let updated = Date(timeIntervalSinceNow: -86400 * 5) // 5 days ago

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            updated: updated
        )

        // When
        let result = issue.isBlocked

        // Then
        XCTAssertTrue(result, "Issue stagnant for 5 days should be blocked")
    }

    func testIsBlocked_ShouldReturnFalse_WhenStagnantForLessThan3Days() {
        // Given
        let updated = Date(timeIntervalSinceNow: -86400 * 2) // 2 days ago

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            updated: updated
        )

        // When
        let result = issue.isBlocked

        // Then
        XCTAssertFalse(result, "Issue stagnant for only 2 days should not be blocked")
    }

    func testIsBlocked_ShouldReturnTrue_WhenExactly3Days() {
        // Given
        let updated = Date(timeIntervalSinceNow: -86400 * 3) // Exactly 3 days ago

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            updated: updated
        )

        // When
        let result = issue.isBlocked

        // Then
        XCTAssertTrue(result, "Issue stagnant for exactly 3 days should be blocked")
    }

    func testIsBlocked_ShouldReturnFalse_WhenNoDaysInCurrentStatus() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "In Progress"),
            issueType: IssueType(name: "Story"),
            updated: nil
        )

        // When
        let result = issue.isBlocked

        // Then
        XCTAssertFalse(result, "Issue without time data should not be blocked")
    }

    func testIsBlocked_ShouldReturnFalse_WhenCancelledAndStagnant() {
        // Given
        let updated = Date(timeIntervalSinceNow: -86400 * 10) // 10 days ago

        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "Cancelled"),
            issueType: IssueType(name: "Story"),
            updated: updated
        )

        // When
        let result = issue.isBlocked

        // Then
        // Note: Cancelled is NOT in isCompleted check (only Done/Terminé/Closed)
        // So Cancelled issues CAN be marked as blocked if stagnant
        XCTAssertTrue(result, "Cancelled issues can be blocked if stagnant")
    }

    // MARK: - Tests for isHighPriority

    func testIsHighPriority_ShouldReturnTrue_WhenPriorityIsHigh() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "To Do"),
            priority: IssuePriority(name: "High"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isHighPriority

        // Then
        XCTAssertTrue(result)
    }

    func testIsHighPriority_ShouldReturnTrue_WhenPriorityIsHighest() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "To Do"),
            priority: IssuePriority(name: "Highest"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isHighPriority

        // Then
        XCTAssertTrue(result)
    }

    func testIsHighPriority_ShouldReturnFalse_WhenPriorityIsMedium() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "To Do"),
            priority: IssuePriority(name: "Medium"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isHighPriority

        // Then
        XCTAssertFalse(result)
    }

    func testIsHighPriority_ShouldReturnFalse_WhenPriorityIsNil() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "To Do"),
            priority: nil,
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.isHighPriority

        // Then
        XCTAssertFalse(result)
    }

    // MARK: - Tests for assigneeName

    func testAssigneeName_ShouldReturnDisplayName_WhenAssigneeExists() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "To Do"),
            assignee: User(displayName: "John Doe"),
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.assigneeName

        // Then
        XCTAssertEqual(result, "John Doe")
    }

    func testAssigneeName_ShouldReturnUnassigned_WhenAssigneeIsNil() {
        // Given
        let issue = Issue(
            id: "1",
            key: "TEST-1",
            summary: "Test",
            status: IssueStatus(name: "To Do"),
            assignee: nil,
            issueType: IssueType(name: "Story")
        )

        // When
        let result = issue.assigneeName

        // Then
        XCTAssertEqual(result, "Unassigned")
    }
}
