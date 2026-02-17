//
//  SprintMapperTests.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

/// Tests for SprintMapper
final class SprintMapperTests: XCTestCase {

    func testToDomain_ShouldMapAllFields() {
        // Given
        let dto = JiraSprintDTO(
            id: 123,
            name: "Sprint 25",
            state: "active",
            startDate: "2026-02-01T00:00:00.000Z",
            endDate: "2026-02-15T00:00:00.000Z",
            goal: "Complete feature X"
        )

        // When
        let result = SprintMapper.toDomain(dto)

        // Then
        XCTAssertEqual(result.id, 123)
        XCTAssertEqual(result.name, "Sprint 25")
        XCTAssertEqual(result.state, .active)
        XCTAssertNotNil(result.startDate)
        XCTAssertNotNil(result.endDate)
        XCTAssertEqual(result.goal, "Complete feature X")
        XCTAssertTrue(result.isActive)
    }

    func testToDomain_ShouldMapStateCorrectly() {
        // Given
        let activeDTO = JiraSprintDTO(id: 1, name: "Sprint 1", state: "active", startDate: nil, endDate: nil, goal: nil)
        let closedDTO = JiraSprintDTO(id: 2, name: "Sprint 2", state: "closed", startDate: nil, endDate: nil, goal: nil)
        let futureDTO = JiraSprintDTO(id: 3, name: "Sprint 3", state: "future", startDate: nil, endDate: nil, goal: nil)

        // When
        let active = SprintMapper.toDomain(activeDTO)
        let closed = SprintMapper.toDomain(closedDTO)
        let future = SprintMapper.toDomain(futureDTO)

        // Then
        XCTAssertEqual(active.state, .active)
        XCTAssertEqual(closed.state, .closed)
        XCTAssertEqual(future.state, .future)
    }

    func testToDomain_ShouldParseDatesCorrectly() {
        // Given
        let dto = JiraSprintDTO(
            id: 1,
            name: "Sprint",
            state: "active",
            startDate: "2026-02-01T10:30:45.123Z",
            endDate: "2026-02-15T18:45:30.456Z",
            goal: nil
        )

        // When
        let result = SprintMapper.toDomain(dto)

        // Then
        XCTAssertNotNil(result.startDate)
        XCTAssertNotNil(result.endDate)
    }

    func testToDomain_ShouldHandleNullDates() {
        // Given
        let dto = JiraSprintDTO(
            id: 1,
            name: "Sprint",
            state: "future",
            startDate: nil,
            endDate: nil,
            goal: nil
        )

        // When
        let result = SprintMapper.toDomain(dto)

        // Then
        XCTAssertNil(result.startDate)
        XCTAssertNil(result.endDate)
    }

    func testToDomain_ShouldMapArrayOfDTOs() {
        // Given
        let dtos = [
            JiraSprintDTO(id: 1, name: "Sprint 1", state: "active", startDate: nil, endDate: nil, goal: nil),
            JiraSprintDTO(id: 2, name: "Sprint 2", state: "closed", startDate: nil, endDate: nil, goal: nil)
        ]

        // When
        let result = SprintMapper.toDomain(dtos)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[1].id, 2)
    }
}
