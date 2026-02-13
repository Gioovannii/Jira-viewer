import SwiftUI

@main
struct JiraViewerApp: App {
    @StateObject private var jiraManager = JiraManager()
    @StateObject private var oauthManager = OAuthManager()

    init() {
        _jiraManager = StateObject(wrappedValue: JiraManager())
        _oauthManager = StateObject(wrappedValue: OAuthManager())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(jiraManager)
                .environmentObject(oauthManager)
                .frame(minWidth: 1000, minHeight: 600)
                .onAppear {
                    jiraManager.oauthManager = oauthManager
                }
                .onOpenURL { url in
                    // Handle OAuth callback
                    if url.scheme == "jiraviewer" {
                        Task {
                            await oauthManager.handleCallback(url: url)
                        }
                    }
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsView()
                .environmentObject(jiraManager)
                .environmentObject(oauthManager)
        }
    }
}
