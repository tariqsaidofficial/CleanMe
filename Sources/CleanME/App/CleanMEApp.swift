import SwiftUI

@main
struct MacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup("Main Window") {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(appSettings)
                .onAppear {
                    setupLogging()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unifiedCompact)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem, addition: { })
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
                .environmentObject(appSettings)
                .environmentObject(themeManager)
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