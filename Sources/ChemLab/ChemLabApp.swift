import ChemLabUI
import SwiftUI

@main
struct ChemLabApp: App {
    init() {
        #if os(macOS)
            // Running via `swift run` has no app bundle, so ask for a normal window.
            NSApplication.shared.setActivationPolicy(.regular)
            DispatchQueue.main.async { NSApplication.shared.activate(ignoringOtherApps: true) }
        #endif
    }

    var body: some Scene {
        WindowGroup("ChemLab") {
            ChemLabRootView()
        }
        .defaultSize(width: 1100, height: 780)
    }
}
