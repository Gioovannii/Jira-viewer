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
    private let oauthManager: OAuthManager

    // MARK: - Initialization

    init(
        fetchSprintsUseCase: FetchSprintsUseCase,
        configRepository: ConfigRepositoryProtocol,
        oauthManager: OAuthManager
    ) {
        self.fetchSprintsUseCase = fetchSprintsUseCase
        self.configRepository = configRepository
        self.oauthManager = oauthManager
    }

    // MARK: - Public Methods

    /// Loads sprints from the API
    func loadSprints() async {
        guard oauthManager.isAuthenticated else {
            errorMessage = "Please sign in to your Atlassian account in Preferences (⌘,)."
            return
        }

        guard configRepository.isConfigured else {
            errorMessage = "Please set your Project Key in Preferences (⌘,)."
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
        oauthManager.isAuthenticated && configRepository.isConfigured
    }
}
