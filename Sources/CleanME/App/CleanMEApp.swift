import SwiftUI

// MARK: - Notification Names (Shared)
extension Notification.Name {
    static let startScanShortcut = Notification.Name("startScanShortcut")
    static let cleanSelectedShortcut = Notification.Name("cleanSelectedShortcut")
    static let refreshResultsShortcut = Notification.Name("refreshResultsShortcut")
    static let selectAllScanTypes = Notification.Name("selectAllScanTypes")
    static let selectAllResults = Notification.Name("selectAllResults")
    static let showShortcutsMenu = Notification.Name("showShortcutsMenu")
}

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
            
            // Add keyboard shortcuts as menu commands
            CommandGroup(after: .newItem) {
                Button("Start Scan") {
                    print("🚀 Menu: Start Scan pressed")
                    NotificationCenter.default.post(name: .startScanShortcut, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
                
                Button("Clean Selected") {
                    print("🧹 Menu: Clean Selected pressed")
                    NotificationCenter.default.post(name: .cleanSelectedShortcut, object: nil)
                }
                .keyboardShortcut("k", modifiers: .command)
                
                Button("Refresh Results") {
                    print("🔄 Menu: Refresh Results pressed")
                    NotificationCenter.default.post(name: .refreshResultsShortcut, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)
                
                Divider()
                
                Button("Select All") {
                    print("✅ Menu: Select All pressed")
                    NotificationCenter.default.post(name: .selectAllScanTypes, object: nil)
                    NotificationCenter.default.post(name: .selectAllResults, object: nil)
                }
                .keyboardShortcut("a", modifiers: .command)
                
                Button("Show Shortcuts") {
                    print("❓ Menu: Show Shortcuts pressed")
                    NotificationCenter.default.post(name: .showShortcutsMenu, object: nil)
                }
                .keyboardShortcut("/", modifiers: .command)
            }
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
        
        // Setup global keyboard shortcuts
        setupGlobalKeyboardShortcuts()
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
    
    private func setupGlobalKeyboardShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            print("🔍 Global Key: \(event.charactersIgnoringModifiers ?? "nil"), modifiers: \(event.modifierFlags)")
            
            guard event.modifierFlags.contains(.command) else { return event }
            guard let chars = event.charactersIgnoringModifiers else { return event }
            
            print("✅ Global Processing command+\(chars)")
            
            switch chars {
            case "s":
                print("🚀 Global: Start Scan")
                NotificationCenter.default.post(name: .startScanShortcut, object: nil)
                return nil
            case "k":
                print("🧹 Global: Clean Selected")
                NotificationCenter.default.post(name: .cleanSelectedShortcut, object: nil)
                return nil
            case "r":
                print("🔄 Global: Refresh Results")
                NotificationCenter.default.post(name: .refreshResultsShortcut, object: nil)
                return nil
            case ",":
                print("⚙️ Global: Open Settings")
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                return nil
            case "/":
                print("❓ Global: Show Shortcuts")
                NotificationCenter.default.post(name: .showShortcutsMenu, object: nil)
                return nil
            case "a":
                print("✅ Global: Select All")
                NotificationCenter.default.post(name: .selectAllScanTypes, object: nil)
                NotificationCenter.default.post(name: .selectAllResults, object: nil)
                return nil
            default:
                return event
            }
        }
    }
}