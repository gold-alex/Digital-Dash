import SwiftUI

@main
struct DigitalDashApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // No main window, so we use an empty view
        }
    }
}

