import SwiftUI

@main
struct CleanMEApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appSettings)
                .frame(minWidth: 900, minHeight: 600)
                .onAppear {
                    setupLogging()
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
            SidebarCommands()
            ToolbarCommands()
        }
        
        Settings {
            SettingsView()
                .environmentObject(appSettings)
                .frame(minWidth: 600, minHeight: 400)
        }
    }
    
    private func setupLogging() {
        Logger.shared.setupLogFile()
        Logger.shared.log("CleanME Application Started", level: .info)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Bring app to front on launch
        NSApp.activate(ignoringOtherApps: true)
        
        // Set up window appearance
        if let window = NSApp.windows.first {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}