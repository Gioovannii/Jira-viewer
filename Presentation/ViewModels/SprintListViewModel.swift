//
//  SprintListViewModel.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

/// ViewModel for the sprint list (MVVM pattern)
@MainActor
final class SprintListViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var sprints: [Sprint] = []
    @Published var selectedSprint: Sprint?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let fetchSprintsUseCase: FetchSprintsUseCase
    private let configRepository: ConfigRepositoryProtocol

    // MARK: - Initialization

    init(
        fetchSprintsUseCase: FetchSprintsUseCase,
        configRepository: ConfigRepositoryProtocol
    ) {
        self.fetchSprintsUseCase = fetchSprintsUseCase
        self.configRepository = configRepository
    }

    // MARK: - Public Methods

    /// Loads sprints from the API
    func loadSprints() async {
        guard configRepository.isConfigured else {
            errorMessage = "Configuration required. Please configure your Jira token."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            sprints = try await fetchSprintsUseCase.execute()

            // Select the first active sprint by default
            if selectedSprint == nil {
                selectedSprint = sprints.first(where: { $0.isActive })
            }
        } catch {
            errorMessage = "Failed to load sprints: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Selects a sprint
    func selectSprint(_ sprint: Sprint) {
        selectedSprint = sprint
    }

    /// Checks if the configuration is complete
    var isConfigured: Bool {
        configRepository.isConfigured
    }
}
