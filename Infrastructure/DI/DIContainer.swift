//
//  DIContainer.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation

/// Simple manual DI container (without external dependency)
/// Replaces Swinject to avoid compilation issues
final class DIContainer {
    static let shared = DIContainer()

    // MARK: - Infrastructure Layer (Singletons)

    private lazy var _networkClient: NetworkClientProtocol = {
        NetworkClient()
    }()

    private lazy var _secureStorage: SecureStorageProtocol = {
        KeychainService()
    }()

    private lazy var _userDefaultsStorage: UserDefaultsStorage = {
        UserDefaultsStorage()
    }()

    // MARK: - Data Layer (Singletons)

    private lazy var _configRepository: ConfigRepositoryProtocol = {
        ConfigRepository(
            secureStorage: _secureStorage,
            userDefaultsStorage: _userDefaultsStorage
        )
    }()

    private lazy var _jiraAPIClient: JiraAPIClient = {
        JiraAPIClient(
            networkClient: _networkClient,
            configRepository: _configRepository
        )
    }()

    private lazy var _sprintRepository: SprintRepositoryProtocol = {
        SprintRepository(apiClient: _jiraAPIClient)
    }()

    private lazy var _issueRepository: IssueRepositoryProtocol = {
        IssueRepository(apiClient: _jiraAPIClient)
    }()

    // MARK: - Domain Layer (Use Cases)

    private lazy var _fetchSprintsUseCase: FetchSprintsUseCase = {
        FetchSprintsUseCase(
            sprintRepository: _sprintRepository,
            configRepository: _configRepository
        )
    }()

    private lazy var _fetchIssuesUseCase: FetchIssuesUseCase = {
        FetchIssuesUseCase(
            issueRepository: _issueRepository,
            configRepository: _configRepository
        )
    }()

    private lazy var _generateSprintReviewUseCase: GenerateSprintReviewUseCase = {
        GenerateSprintReviewUseCase()
    }()

    // MARK: - Presentation Layer (ViewModels - new instances)

    private init() {}

    // MARK: - Public Accessors

    var networkClient: NetworkClientProtocol {
        _networkClient
    }

    var secureStorage: SecureStorageProtocol {
        _secureStorage
    }

    var configRepository: ConfigRepositoryProtocol {
        _configRepository
    }

    // MARK: - ViewModels (new instances each time)

    @MainActor
    var sprintListViewModel: SprintListViewModel {
        SprintListViewModel(
            fetchSprintsUseCase: _fetchSprintsUseCase,
            configRepository: _configRepository
        )
    }

    @MainActor
    var issueListViewModel: IssueListViewModel {
        IssueListViewModel(
            fetchIssuesUseCase: _fetchIssuesUseCase
        )
    }

    @MainActor
    var settingsViewModel: SettingsViewModel {
        SettingsViewModel(
            configRepository: _configRepository
        )
    }

    @MainActor
    func makeIssueDetailViewModel(issue: Issue) -> IssueDetailViewModel {
        IssueDetailViewModel(
            issue: issue,
            configRepository: _configRepository
        )
    }

    @MainActor
    func makeSprintReviewViewModel(sprint: Sprint, issues: [Issue]) -> SprintReviewViewModel {
        SprintReviewViewModel(
            sprint: sprint,
            issues: issues,
            generateSprintReviewUseCase: _generateSprintReviewUseCase
        )
    }
}
