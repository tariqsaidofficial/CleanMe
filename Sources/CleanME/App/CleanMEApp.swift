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
    private var menuBarManager: MenuBarManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize Menu Bar Manager
        Task { @MainActor in
            menuBarManager = MenuBarManager.shared
        }
        
        // Bring app to front on launch
        NSApp.activate(ignoringOtherApps: true)
        
        // Set up window appearance
        if let window = NSApp.windows.first {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
        }
        
        // Setup notification observers
        setupNotificationObservers()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Don't quit when main window closes - keep menu bar icon active
        return false
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Clean up
        Task { @MainActor in
            menuBarManager?.stopMonitoring()
        }
    }
    
    private func setupNotificationObservers() {
        // Listen for quick scan requests from menu bar
        NotificationCenter.default.addObserver(
            forName: .performQuickScan,
            object: nil,
            queue: .main
        ) { _ in
            // Activate app and trigger scan
            NSApp.activate(ignoringOtherApps: true)
            // TODO: Trigger scan in ContentView
        }
        
        // Listen for preferences open requests
        NotificationCenter.default.addObserver(
            forName: .openPreferences,
            object: nil,
            queue: .main
        ) { _ in
            // Open settings window
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
    }
}