//
//  FetchSprintsUseCaseTests.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import XCTest

/// Tests for FetchSprintsUseCase
final class FetchSprintsUseCaseTests: XCTestCase {
    var sut: FetchSprintsUseCase!
    var mockSprintRepo: MockSprintRepository!
    var mockConfigRepo: MockConfigRepository!

    override func setUp() {
        super.setUp()
        mockSprintRepo = MockSprintRepository()
        mockConfigRepo = MockConfigRepository()
        sut = FetchSprintsUseCase(
            sprintRepository: mockSprintRepo,
            configRepository: mockConfigRepo
        )
    }

    override func tearDown() {
        sut = nil
        mockSprintRepo = nil
        mockConfigRepo = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testExecute_ShouldReturnSortedSprints_ActiveFirst() async throws {
        // Given
        let inactiveSprint = Sprint(id: 1, name: "Sprint 1", state: .closed, startDate: Date())
        let activeSprint = Sprint(id: 2, name: "Sprint 2", state: .active, startDate: Date())
        mockSprintRepo.sprintsToReturn = [inactiveSprint, activeSprint]

        // When
        let result = try await sut.execute()

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result[0].isActive, "The first sprint should be active")
        XCTAssertEqual(result[0].id, 2)
        XCTAssertEqual(result[1].id, 1)
    }

    func testExecute_ShouldSortByDateWhenNoActiveSprints() async throws {
        // Given
        let olderSprint = Sprint(
            id: 1,
            name: "Sprint 1",
            state: .closed,
            startDate: Date().addingTimeInterval(-86400 * 30)
        )
        let newerSprint = Sprint(
            id: 2,
            name: "Sprint 2",
            state: .closed,
            startDate: Date().addingTimeInterval(-86400 * 15)
        )
        mockSprintRepo.sprintsToReturn = [olderSprint, newerSprint]

        // When
        let result = try await sut.execute()

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 2, "The most recent sprint should be first")
        XCTAssertEqual(result[1].id, 1)
    }

    func testExecute_ShouldUseProjectKeyFromConfig() async throws {
        // Given
        mockConfigRepo.projectKey = "MYPROJECT"
        mockSprintRepo.sprintsToReturn = []

        // When
        _ = try await sut.execute()

        // Then
        XCTAssertTrue(mockSprintRepo.fetchSprintsCalled)
    }

    func testExecute_ShouldThrowError_WhenRepositoryFails() async {
        // Given
        mockSprintRepo.shouldThrowError = true
        mockSprintRepo.errorToThrow = NetworkError.unauthorized

        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Should throw an error")
        } catch {
            XCTAssertTrue(error is NetworkError)
        }
    }
}
