import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var oauthManager: OAuthManager
    @AppStorage("jiraBaseURL") private var jiraBaseURL = "https://jira.ets.mpi-internal.com"
    @AppStorage("jiraUsername") private var jiraUsername = ""
    @AppStorage("jiraToken") private var jiraToken = ""
    @AppStorage("claudeAPIKey") private var claudeAPIKey = ""
    @AppStorage("projectKey") private var projectKey = "LBCMONSPE"
    @AppStorage("authMethod") private var authMethodRaw = AuthMethod.basicAuth.rawValue

    @State private var showingOAuthLogin = false

    private var authMethod: AuthMethod {
        get { AuthMethod(rawValue: authMethodRaw) ?? .basicAuth }
        set { authMethodRaw = newValue.rawValue }
    }

    var body: some View {
        Form {
            Section("Configuration Jira") {
                TextField("URL Jira", text: $jiraBaseURL)
                    .textFieldStyle(.roundedBorder)

                TextField("Clé du projet", text: $projectKey)
                    .textFieldStyle(.roundedBorder)
            }

            Section("Méthode d'Authentification") {
                Picker("Méthode", selection: Binding(
                    get: { authMethod },
                    set: { authMethodRaw = $0.rawValue }
                )) {
                    Text("Authentification Basique").tag(AuthMethod.basicAuth)
                    Text("Okta SSO (OAuth)").tag(AuthMethod.oauth)
                }
                .pickerStyle(.segmented)
            }

            if authMethod == .oauth {
                Section("Okta SSO") {
                    if oauthManager.isAuthenticated {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Connecté")
                                    .fontWeight(.semibold)
                            }

                            if let email = oauthManager.userEmail {
                                Text("Utilisateur: \(email)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Button("Se déconnecter") {
                                oauthManager.logout()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                        .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Connectez-vous avec votre compte Okta pour accéder à Jira.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: {
                                showingOAuthLogin = true
                            }) {
                                Label("Se connecter avec Okta SSO", systemImage: "person.badge.key")
                            }
                            .buttonStyle(.borderedProminent)

                            if let error = oauthManager.authenticationError {
                                Text("Erreur: \(error)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            } else {
                Section("Authentification Basique") {
                    TextField("Nom d'utilisateur", text: $jiraUsername)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Token API / Mot de passe", text: $jiraToken)
                        .textFieldStyle(.roundedBorder)

                    Text("Pour Jira Server, utilisez votre mot de passe. Pour Jira Cloud, créez un API token depuis votre profil Atlassian.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
        .frame(width: 600, height: 600)
        .sheet(isPresented: $showingOAuthLogin) {
            OAuthLoginWindow(oauthManager: oauthManager)
        }
    }
}

#Preview {
    SettingsView()
}
