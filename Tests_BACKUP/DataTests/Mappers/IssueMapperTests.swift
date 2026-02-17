//
//  IssueMapperTests.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

/// Tests for IssueMapper
final class IssueMapperTests: XCTestCase {

    func testToDomain_ShouldMapAllBasicFields() {
        // Given
        let dto = createIssueDTO(
            id: "123",
            key: "PROJ-456",
            summary: "Test issue",
            statusName: "Done"
        )

        // When
        let result = IssueMapper.toDomain(dto)

        // Then
        XCTAssertEqual(result.id, "123")
        XCTAssertEqual(result.key, "PROJ-456")
        XCTAssertEqual(result.summary, "Test issue")
        XCTAssertEqual(result.status.name, "Done")
    }

    func testToDomain_ShouldMapOptionalFields() {
        // Given
        let dto = createIssueDTO(
            assigneeName: "John Doe",
            priorityName: "High",
            description: "Test description"
        )

        // When
        let result = IssueMapper.toDomain(dto)

        // Then
        XCTAssertNotNil(result.assignee)
        XCTAssertEqual(result.assignee?.displayName, "John Doe")
        XCTAssertNotNil(result.priority)
        XCTAssertEqual(result.priority?.name, "High")
        XCTAssertEqual(result.description, "Test description")
    }

    func testToDomain_ShouldParseDates() {
        // Given
        let dto = createIssueDTO(
            created: "2026-02-01T10:30:45.123Z",
            updated: "2026-02-10T15:20:30.456Z"
        )

        // When
        let result = IssueMapper.toDomain(dto)

        // Then
        XCTAssertNotNil(result.created)
        XCTAssertNotNil(result.updated)
    }

    func testToDomain_ShouldResolveDate_FromResolutionDate() {
        // Given
        let dto = createIssueDTO(
            statusName: "Done",
            resolutionDate: "2026-02-15T12:00:00.000Z"
        )

        // When
        let result = IssueMapper.toDomain(dto)

        // Then
        XCTAssertNotNil(result.resolved)
    }

    func testToDomain_ShouldResolveDate_FromUpdatedWhenDone() {
        // Given
        let dto = createIssueDTO(
            statusName: "Done",
            updated: "2026-02-15T12:00:00.000Z",
            resolutionDate: nil
        )

        // When
        let result = IssueMapper.toDomain(dto)

        // Then
        XCTAssertNotNil(result.resolved, "Should use updated as fallback for Done")
    }

    func testToDomain_ShouldNotResolveDate_WhenNotDone() {
        // Given
        let dto = createIssueDTO(
            statusName: "In Progress",
            updated: "2026-02-15T12:00:00.000Z",
            resolutionDate: nil
        )

        // When
        let result = IssueMapper.toDomain(dto)

        // Then
        XCTAssertNil(result.resolved, "Should not have resolution date for In Progress")
    }

    func testToDomain_ShouldMapTimeTracking() {
        // Given
        let dto = createIssueDTO(
            timeSpent: 3600,
            timeEstimate: 7200
        )

        // When
        let result = IssueMapper.toDomain(dto)

        // Then
        XCTAssertNotNil(result.timeTracking)
        XCTAssertEqual(result.timeTracking?.timeSpentSeconds, 3600)
        XCTAssertEqual(result.timeTracking?.originalEstimateSeconds, 7200)
    }

    func testToDomain_ShouldMapArrayOfDTOs() {
        // Given
        let dtos = [
            createIssueDTO(id: "1", key: "PROJ-1"),
            createIssueDTO(id: "2", key: "PROJ-2")
        ]

        // When
        let result = IssueMapper.toDomain(dtos)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, "1")
        XCTAssertEqual(result[1].id, "2")
    }

    // MARK: - Helpers

    private func createIssueDTO(
        id: String = "123",
        key: String = "PROJ-123",
        summary: String = "Test",
        statusName: String = "To Do",
        assigneeName: String? = nil,
        priorityName: String? = nil,
        description: String? = nil,
        created: String? = nil,
        updated: String? = nil,
        resolutionDate: String? = nil,
        timeSpent: Int? = nil,
        timeEstimate: Int? = nil
    ) -> JiraIssueDTO {
        let assignee = assigneeName.map {
            JiraIssueDTO.JiraUserDTO(displayName: $0, emailAddress: nil)
        }
        let priority = priorityName.map {
            JiraIssueDTO.IssuePriorityDTO(name: $0)
        }
        let timeTracking = (timeSpent != nil || timeEstimate != nil) ?
            JiraIssueDTO.TimeTrackingDTO(
                originalEstimateSeconds: timeEstimate,
                remainingEstimateSeconds: nil,
                timeSpentSeconds: timeSpent
            ) : nil

        let fields = JiraIssueDTO.IssueFieldsDTO(
            summary: summary,
            description: description,
            status: JiraIssueDTO.IssueStatusDTO(name: statusName),
            assignee: assignee,
            priority: priority,
            issuetype: JiraIssueDTO.IssueTypeDTO(name: "Story", iconUrl: nil),
            created: created,
            updated: updated,
            resolutiondate: resolutionDate,
            sprint: nil,
            timetracking: timeTracking
        )

        return JiraIssueDTO(id: id, key: key, fields: fields)
    }
}
