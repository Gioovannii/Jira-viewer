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
    @ObservedObject var oauthManager: OAuthManager

    init(viewModel: SettingsViewModel? = nil, oauthManager: OAuthManager? = nil) {
        self.viewModel = viewModel ?? DIContainer.shared.settingsViewModel
        self.oauthManager = oauthManager ?? DIContainer.shared.oauthManager
    }

    var body: some View {
        Form {
            Section("Jira Configuration") {
                TextField("Project Key (e.g. LBCMONSPE)", text: $viewModel.projectKey)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.projectKey) { _ in viewModel.saveConfiguration() }
            }

            Section("Authentication") {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Jira Cloud — OAuth 2.0")
                        .font(.headline)

                    if oauthManager.isAuthenticated {
                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            VStack(alignment: .leading) {
                                Text("Connected to Atlassian")
                                    .fontWeight(.semibold)
                                Text("Your account is authorized.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Button("Disconnect") {
                                oauthManager.logout()
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sign in with your Atlassian account to access Jira.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button {
                                Task { await oauthManager.login() }
                            } label: {
                                HStack {
                                    if oauthManager.isAuthenticating {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                    }
                                    Text(oauthManager.isAuthenticating ? "Signing in..." : "Sign in with Atlassian")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(oauthManager.isAuthenticating)

                            if let error = oauthManager.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Advanced") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Flagged Field ID")
                        .font(.headline)

                    Text("Custom field ID for flagged/blocked issues. Default is customfield_10021.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Flagged Field ID", text: $viewModel.flaggedFieldId)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                        .onChange(of: viewModel.flaggedFieldId) { _ in
                            viewModel.saveFlaggedFieldId()
                        }
                }
                .padding(.vertical, 8)
            }

            Section("About") {
                Text("Jira Viewer")
                    .font(.headline)
                Text("Version 3.0 — OAuth 2.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 540, height: 480)
        .onAppear {
            viewModel.loadConfiguration()
        }
    }
}

#Preview {
    SettingsView()
}
