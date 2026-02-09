import SwiftUI

@main
struct JiraViewerApp: App {
    @StateObject private var jiraManager = JiraManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(jiraManager)
                .frame(minWidth: 1000, minHeight: 600)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsView()
                .environmentObject(jiraManager)
        }
    }
}
