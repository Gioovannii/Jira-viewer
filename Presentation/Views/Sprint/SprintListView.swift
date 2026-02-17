//
//  SprintListView.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View for the sprint list (sidebar)
struct SprintListView: View {
    @ObservedObject var viewModel: SprintListViewModel
    @Binding var selectedSprint: Sprint?

    var body: some View {
        List(selection: $selectedSprint) {
            Section("Sprints") {
                ForEach(viewModel.sprints) { sprint in
                    SprintRow(sprint: sprint)
                        .tag(sprint)
                }
            }
        }
        .navigationTitle("Sprints")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    Task {
                        await viewModel.loadSprints()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
                .controlSize(.large)
                .tint(.accentColor)
                .disabled(viewModel.isLoading)
            }
        }
        .onChange(of: selectedSprint) { newValue in
            if let sprint = newValue {
                viewModel.selectSprint(sprint)
            }
        }
        .task {
            if viewModel.sprints.isEmpty {
                await viewModel.loadSprints()
            }
        }
    }
}

#Preview {
    let container = DIContainer.shared
    let viewModel = container.sprintListViewModel

    return NavigationStack {
        SprintListView(
            viewModel: viewModel,
            selectedSprint: .constant(nil)
        )
    }
}
