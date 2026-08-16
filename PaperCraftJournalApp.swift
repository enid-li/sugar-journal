import SwiftUI

@main
struct PaperCraftJournalApp: App {

    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
        }
    }
}