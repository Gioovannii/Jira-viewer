import SwiftUI

struct SettingsView: View {
    @AppStorage("jiraBaseURL") private var jiraBaseURL = "https://jira.ets.mpi-internal.com"
    @AppStorage("jiraUsername") private var jiraUsername = ""
    @AppStorage("jiraToken") private var jiraToken = ""
    @AppStorage("claudeAPIKey") private var claudeAPIKey = ""
    @AppStorage("projectKey") private var projectKey = "LBCMONSPE"

    var body: some View {
        Form {
            Section("Configuration Jira") {
                TextField("URL Jira", text: $jiraBaseURL)
                    .textFieldStyle(.roundedBorder)

                TextField("Nom d'utilisateur", text: $jiraUsername)
                    .textFieldStyle(.roundedBorder)

                SecureField("Token API / Mot de passe", text: $jiraToken)
                    .textFieldStyle(.roundedBorder)

                TextField("Clé du projet", text: $projectKey)
                    .textFieldStyle(.roundedBorder)

                Text("Pour Jira Server, utilisez votre mot de passe. Pour Jira Cloud, créez un API token depuis votre profil Atlassian.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Configuration Claude AI") {
                SecureField("Clé API Claude", text: $claudeAPIKey)
                    .textFieldStyle(.roundedBorder)

                Link("Obtenir une clé API", destination: URL(string: "https://console.anthropic.com/")!)
                    .font(.caption)
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
        .frame(width: 500, height: 400)
    }
}

#Preview {
    SettingsView()
}
