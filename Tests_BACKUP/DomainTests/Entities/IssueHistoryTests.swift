//
//  IssueHistoryTests.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest
@testable import JiraViewer

final class IssueHistoryTests: XCTestCase {

    // MARK: - Tests for timeInStatus

    func testTimeInStatus_ShouldReturnCorrectDuration_WhenStatusExists() {
        // Given
        let date1 = Date(timeIntervalSince1970: 0)
        let date2 = Date(timeIntervalSince1970: 86400 * 5) // 5 days later
        let date3 = Date(timeIntervalSince1970: 86400 * 8) // 3 days later

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: date1,
                author: "User1"
            ),
            StatusTransition(
                id: "2",
                fromStatus: "In Progress",
                toStatus: "Review",
                transitionDate: date2,
                author: "User2"
            ),
            StatusTransition(
                id: "3",
                fromStatus: "Review",
                toStatus: "Done",
                transitionDate: date3,
                author: "User3"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.timeInStatus("In Progress")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 86400 * 5, accuracy: 1.0) // 5 days in seconds
    }

    func testTimeInStatus_ShouldReturnNil_WhenStatusDoesNotExist() {
        // Given
        let date1 = Date(timeIntervalSince1970: 0)

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "Done",
                transitionDate: date1,
                author: "User1"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.timeInStatus("In Progress")

        // Then
        XCTAssertNil(result)
    }

    func testTimeInStatus_ShouldBeCaseInsensitive() {
        // Given
        let date1 = Date(timeIntervalSince1970: 0)
        let date2 = Date(timeIntervalSince1970: 86400 * 3)

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: date1,
                author: "User1"
            ),
            StatusTransition(
                id: "2",
                fromStatus: "In Progress",
                toStatus: "Done",
                transitionDate: date2,
                author: "User2"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.timeInStatus("in progress")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 86400 * 3, accuracy: 1.0)
    }

    func testTimeInStatus_ShouldReturnNil_WhenTransitionsEmpty() {
        // Given
        let history = IssueHistory(transitions: [])

        // When
        let result = history.timeInStatus("In Progress")

        // Then
        XCTAssertNil(result)
    }

    // MARK: - Tests for currentStatusDuration

    func testCurrentStatusDuration_ShouldReturnDurationSinceLastTransition() {
        // Given
        let lastTransitionDate = Date(timeIntervalSinceNow: -86400 * 4) // 4 days ago

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: lastTransitionDate,
                author: "User1"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.currentStatusDuration(currentStatus: "In Progress")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 86400 * 4, accuracy: 100.0) // 4 days in seconds (with tolerance)
    }

    func testCurrentStatusDuration_ShouldReturnNil_WhenNoTransitionsToCurrentStatus() {
        // Given
        let date = Date(timeIntervalSinceNow: -86400)

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "Review",
                transitionDate: date,
                author: "User1"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.currentStatusDuration(currentStatus: "In Progress")

        // Then
        XCTAssertNil(result)
    }

    func testCurrentStatusDuration_ShouldBeCaseInsensitive() {
        // Given
        let lastTransitionDate = Date(timeIntervalSinceNow: -86400 * 2)

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: lastTransitionDate,
                author: "User1"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.currentStatusDuration(currentStatus: "in progress")

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!, 86400 * 2, accuracy: 100.0)
    }

    // MARK: - Tests for allStatuses

    func testAllStatuses_ShouldReturnAllUniqueStatuses() {
        // Given
        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: Date(),
                author: "User1"
            ),
            StatusTransition(
                id: "2",
                fromStatus: "In Progress",
                toStatus: "Review",
                transitionDate: Date(),
                author: "User2"
            ),
            StatusTransition(
                id: "3",
                fromStatus: "Review",
                toStatus: "Done",
                transitionDate: Date(),
                author: "User3"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.allStatuses()

        // Then
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result.contains("To Do"))
        XCTAssertTrue(result.contains("In Progress"))
        XCTAssertTrue(result.contains("Review"))
        XCTAssertTrue(result.contains("Done"))
    }

    func testAllStatuses_ShouldReturnEmptyArray_WhenNoTransitions() {
        // Given
        let history = IssueHistory(transitions: [])

        // When
        let result = history.allStatuses()

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func testAllStatuses_ShouldNotContainDuplicates() {
        // Given
        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: Date(),
                author: "User1"
            ),
            StatusTransition(
                id: "2",
                fromStatus: "In Progress",
                toStatus: "To Do",
                transitionDate: Date(),
                author: "User2"
            ),
            StatusTransition(
                id: "3",
                fromStatus: "To Do",
                toStatus: "Done",
                transitionDate: Date(),
                author: "User3"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.allStatuses()

        // Then
        XCTAssertEqual(result.count, 3) // To Do, In Progress, Done (no duplicates)
        XCTAssertTrue(result.contains("To Do"))
        XCTAssertTrue(result.contains("In Progress"))
        XCTAssertTrue(result.contains("Done"))
    }

    // MARK: - Tests for statusDurations

    func testStatusDurations_ShouldReturnDurationForEachStatus() {
        // Given
        let date1 = Date(timeIntervalSince1970: 0)
        let date2 = Date(timeIntervalSince1970: 86400 * 2) // 2 days later
        let date3 = Date(timeIntervalSince1970: 86400 * 5) // 3 days later
        let date4 = Date(timeIntervalSince1970: 86400 * 9) // 4 days later

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: date1,
                author: "User1"
            ),
            StatusTransition(
                id: "2",
                fromStatus: "In Progress",
                toStatus: "Review",
                transitionDate: date2,
                author: "User2"
            ),
            StatusTransition(
                id: "3",
                fromStatus: "Review",
                toStatus: "Testing",
                transitionDate: date3,
                author: "User3"
            ),
            StatusTransition(
                id: "4",
                fromStatus: "Testing",
                toStatus: "Done",
                transitionDate: date4,
                author: "User4"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.statusDurations()

        // Then
        XCTAssertEqual(result.count, 4)
        XCTAssertEqual(result["In Progress"], 86400 * 2, accuracy: 1.0) // 2 days
        XCTAssertEqual(result["Review"], 86400 * 3, accuracy: 1.0) // 3 days
        XCTAssertEqual(result["Testing"], 86400 * 4, accuracy: 1.0) // 4 days
        XCTAssertNotNil(result["Done"]) // Current status, duration from date4 to now
    }

    func testStatusDurations_ShouldReturnEmptyDictionary_WhenNoTransitions() {
        // Given
        let history = IssueHistory(transitions: [])

        // When
        let result = history.statusDurations()

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func testStatusDurations_ShouldHandleMultipleVisitsToSameStatus() {
        // Given
        let date1 = Date(timeIntervalSince1970: 0)
        let date2 = Date(timeIntervalSince1970: 86400 * 2) // 2 days later
        let date3 = Date(timeIntervalSince1970: 86400 * 4) // 2 days later
        let date4 = Date(timeIntervalSince1970: 86400 * 7) // 3 days later

        let transitions = [
            StatusTransition(
                id: "1",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: date1,
                author: "User1"
            ),
            StatusTransition(
                id: "2",
                fromStatus: "In Progress",
                toStatus: "To Do",
                transitionDate: date2,
                author: "User2"
            ),
            StatusTransition(
                id: "3",
                fromStatus: "To Do",
                toStatus: "In Progress",
                transitionDate: date3,
                author: "User3"
            ),
            StatusTransition(
                id: "4",
                fromStatus: "In Progress",
                toStatus: "Done",
                transitionDate: date4,
                author: "User4"
            )
        ]

        let history = IssueHistory(transitions: transitions)

        // When
        let result = history.statusDurations()

        // Then
        // "In Progress" was visited twice: 2 days (date1-date2) + 3 days (date3-date4) = 5 days total
        XCTAssertEqual(result["In Progress"], 86400 * 5, accuracy: 1.0)
        // "To Do" was visited twice: initially + 2 days (date2-date3)
        XCTAssertEqual(result["To Do"], 86400 * 2, accuracy: 1.0)
    }
}
