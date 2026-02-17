//
//  SprintReviewViewModel.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Combine

/// ViewModel for Sprint Review (MVVM pattern)
@MainActor
final class SprintReviewViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var sprint: Sprint
    @Published var issues: [Issue]
    @Published var sprintReview: SprintReview?
    @Published var isGenerating = false
    @Published var displayedText = ""

    // MARK: - Dependencies

    private let generateSprintReviewUseCase: GenerateSprintReviewUseCase

    // MARK: - Private Properties

    private var animationTask: Task<Void, Never>?

    // MARK: - Initialization

    init(
        sprint: Sprint,
        issues: [Issue],
        generateSprintReviewUseCase: GenerateSprintReviewUseCase
    ) {
        self.sprint = sprint
        self.issues = issues
        self.generateSprintReviewUseCase = generateSprintReviewUseCase
    }

    // MARK: - Computed Properties

    /// Sprint statistics
    var stats: SprintStats {
        let total = issues.count
        let done = issues.filter { $0.isCompleted }.count
        let inProgress = issues.filter { $0.isInProgress }.count
        let todo = total - done - inProgress

        let byType = Dictionary(grouping: issues) { $0.issueType.name }
            .mapValues { $0.count }

        let progress = total > 0 ? Double(done) / Double(total) : 0

        return SprintStats(
            total: total,
            done: done,
            inProgress: inProgress,
            todo: todo,
            byType: byType,
            progress: progress,
            progressPercentage: Int(progress * 100)
        )
    }

    // MARK: - Public Methods

    /// Generates the sprint summary
    func generateReview() async {
        isGenerating = true

        // Execute the use case (synchronous calculation on a separate thread)
        let review = await Task.detached { [self] in
            await generateSprintReviewUseCase.execute(sprint: sprint, issues: issues)
        }.value

        sprintReview = review
        isGenerating = false

        // Start the typing animation
        startTypingAnimation(fullText: review.summaryText)
    }

    /// Updates the sprint and issues
    func update(sprint: Sprint, issues: [Issue]) {
        self.sprint = sprint
        self.issues = issues
        // Reset the review
        self.sprintReview = nil
        self.displayedText = ""
    }

    // MARK: - Private Methods

    private func startTypingAnimation(fullText: String) {
        // Cancel the current animation
        animationTask?.cancel()

        // Reset the text
        displayedText = ""

        // Create a new animation task
        animationTask = Task {
            let lines = fullText.split(separator: "\n", omittingEmptySubsequences: false)

            for line in lines {
                if Task.isCancelled { return }

                await MainActor.run {
                    if !displayedText.isEmpty {
                        displayedText += "\n"
                    }
                    displayedText += String(line)
                }

                // Progressive delay depending on line type
                let delay: UInt64
                if line.hasPrefix("📊") || line.hasPrefix("✅") ||
                   line.hasPrefix("⚠️") || line.hasPrefix("📋") ||
                   line.hasPrefix("💡") || line.hasPrefix("⏱️") {
                    delay = 80_000_000 // 0.08s for titles
                } else if line.isEmpty {
                    delay = 10_000_000 // 0.01s for empty lines
                } else {
                    delay = 30_000_000 // 0.03s for content
                }

                try? await Task.sleep(nanoseconds: delay)
            }
        }
    }

    // MARK: - Cleanup

    func cancelAnimation() {
        animationTask?.cancel()
    }
}

// MARK: - Supporting Types

extension SprintReviewViewModel {
    struct SprintStats {
        let total: Int
        let done: Int
        let inProgress: Int
        let todo: Int
        let byType: [String: Int]
        let progress: Double
        let progressPercentage: Int
    }
}
