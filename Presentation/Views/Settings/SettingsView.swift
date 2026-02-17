//
//  SettingsView.swift
//  JiraViewer
//
//  Copyright © 2024-2026 Jonathan Gaffe. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View for application settings
struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel

    init(viewModel: SettingsViewModel? = nil) {
        self.viewModel = viewModel ?? DIContainer.shared.settingsViewModel
    }

    var body: some View {
        Form {
            Section("Jira Configuration") {
                TextField("Jira URL", text: $viewModel.jiraBaseURL)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)

                TextField("Project Key", text: $viewModel.projectKey)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)

                Text("Pre-configured for your Jira instance")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Authentication") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personal Access Token")
                        .font(.headline)

                    Text("Use your Jira Personal Access Token to authenticate.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SecureField("Personal Access Token", text: $viewModel.jiraToken)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .onChange(of: viewModel.jiraToken) { _ in
                            viewModel.saveConfiguration()
                        }

                    if viewModel.jiraToken.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("How to create a token:")
                                .font(.caption)
                                .fontWeight(.semibold)

                            Text("1. Go to Jira > Profile > Personal Access Tokens")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("2. Click 'Create token'")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("3. Copy and paste the token above")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Token configured")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }

                    // Error or success messages
                    if let error = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    if let success = viewModel.successMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(success)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Security") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(.green)
                        Text("Secure Storage")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text("Your token is securely stored in the macOS Keychain. It is never saved in plain text.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Sprint Summaries") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Local and Private Generation")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text("Sprint summaries are generated locally on your Mac. No data is sent to an external service.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("About") {
                Text("Jira Viewer")
                    .font(.headline)
                Text("Version 2.0 - Clean Architecture")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 600, height: 550)
        .onAppear {
            viewModel.loadConfiguration()
        }
    }
}

#Preview {
    SettingsView()
}
