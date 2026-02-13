import SwiftUI

struct SettingsView: View {
    @AppStorage("jiraBaseURL") private var jiraBaseURL = "https://jira.ets.mpi-internal.com"
    @AppStorage("jiraToken") private var jiraToken = ""
    @AppStorage("projectKey") private var projectKey = "LBCMONSPE"

    var body: some View {
        Form {
            Section("Configuration Jira") {
                TextField("URL Jira", text: $jiraBaseURL)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)

                TextField("Clé du projet", text: $projectKey)
                    .textFieldStyle(.roundedBorder)
                    .disabled(true)

                Text("Configuration pré-définie pour votre instance Jira")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Authentification") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Personal Access Token")
                        .font(.headline)

                    Text("Utilisez votre Personal Access Token Jira pour vous authentifier.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    SecureField("Personal Access Token", text: $jiraToken)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))

                    if jiraToken.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Comment créer un token:")
                                .font(.caption)
                                .fontWeight(.semibold)

                            Text("1. Allez sur Jira > Profile > Personal Access Tokens")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("2. Cliquez 'Create token'")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("3. Copiez et collez le token ci-dessus")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Token configuré")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Résumés de Sprint") {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "checkmark.shield.fill")
                            .foregroundColor(.green)
                        Text("Génération locale et privée")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    Text("Les résumés de sprint sont générés localement sur votre Mac. Aucune donnée n'est envoyée à un service externe.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("À propos") {
                Text("Jira Viewer")
                    .font(.headline)
                Text("Version 1.0")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 600, height: 500)
    }
}

#Preview {
    SettingsView()
}
