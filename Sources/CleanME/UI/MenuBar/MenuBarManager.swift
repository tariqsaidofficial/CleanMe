import AppKit
import SwiftUI

/// Manages the menu bar status item and its interactions
@MainActor
class MenuBarManager: ObservableObject {
    static let shared = MenuBarManager()
    
    // MARK: - Properties
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    @Published var diskSpaceInfo: DiskSpaceInfo?
    @Published var isMonitoring: Bool = false
    
    private var monitorTimer: Timer?
    
    // MARK: - Initialization
    
    private init() {
        setupStatusItem()
        startMonitoring()
    }
    
    // MARK: - Setup
    
    private func setupStatusItem() {
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        guard let button = statusItem?.button else { return }
        
        // Set initial icon
        updateStatusIcon()
        
        // Add click action
        button.action = #selector(statusItemClicked)
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    // MARK: - Actions
    
    @objc private func statusItemClicked(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Right click - show context menu
            showContextMenu()
        } else {
            // Left click - show popover
            togglePopover(sender)
        }
    }
    
    private func togglePopover(_ sender: NSStatusBarButton) {
        if let popover = popover, popover.isShown {
            closePopover()
        } else {
            showPopover(sender)
        }
    }
    
    private func showPopover(_ sender: NSStatusBarButton) {
        // Create popover if needed
        if popover == nil {
            popover = NSPopover()
            popover?.contentSize = NSSize(width: 320, height: 400)
            popover?.behavior = .transient
            popover?.contentViewController = NSHostingController(
                rootView: MenuBarPopoverView()
                    .environmentObject(self)
            )
        }
        
        popover?.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
    }
    
    private func closePopover() {
        popover?.performClose(nil)
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        // Disk Space Info
        if let diskInfo = diskSpaceInfo {
            let infoItem = NSMenuItem(
                title: "💾 \(diskInfo.usedPercentage)% Used (\(diskInfo.freeSpace.formatBytes()) Free)",
                action: nil,
                keyEquivalent: ""
            )
            infoItem.isEnabled = false
            menu.addItem(infoItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        // Quick Scan
        menu.addItem(NSMenuItem(
            title: "🔍 Quick Scan",
            action: #selector(quickScan),
            keyEquivalent: "s"
        ))
        
        // Open App
        menu.addItem(NSMenuItem(
            title: "📱 Open CleanME",
            action: #selector(openMainApp),
            keyEquivalent: "o"
        ))
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings
        menu.addItem(NSMenuItem(
            title: "⚙️ Preferences...",
            action: #selector(openPreferences),
            keyEquivalent: ","
        ))
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        menu.addItem(NSMenuItem(
            title: "Quit CleanME",
            action: #selector(quitApp),
            keyEquivalent: "q"
        ))
        
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    // MARK: - Menu Actions
    
    @objc private func quickScan() {
        NotificationCenter.default.post(name: .performQuickScan, object: nil)
        closePopover()
    }
    
    @objc private func openMainApp() {
        NSApp.activate(ignoringOtherApps: true)
        closePopover()
    }
    
    @objc private func openPreferences() {
        NotificationCenter.default.post(name: .openPreferences, object: nil)
        NSApp.activate(ignoringOtherApps: true)
        closePopover()
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Disk Monitoring
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        isMonitoring = true
        updateDiskSpace()
        
        // Update every 30 seconds
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDiskSpace()
            }
        }
    }
    
    func stopMonitoring() {
        isMonitoring = false
        monitorTimer?.invalidate()
        monitorTimer = nil
    }
    
    private func updateDiskSpace() {
        diskSpaceInfo = DiskSpaceInfo.current()
        updateStatusIcon()
    }
    
    private func updateStatusIcon() {
        guard let button = statusItem?.button else { return }
        
        // Determine icon based on disk usage
        let iconName: String
        if let diskInfo = diskSpaceInfo {
            switch diskInfo.usedPercentage {
            case 0..<70:
                iconName = "checkmark.circle.fill" // Green - Good
            case 70..<85:
                iconName = "exclamationmark.circle.fill" // Yellow - Warning
            default:
                iconName = "xmark.circle.fill" // Red - Critical
            }
        } else {
            iconName = "circle.fill"
        }
        
        button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "CleanME Status")
        button.image?.isTemplate = true
    }
    
    // MARK: - Public Methods
    
    func showNotification(title: String, message: String) {
        // Use NotificationManager for consistent notifications
        NotificationManager.shared.sendNotification(title: title, body: message)
    }
    
    func updateBadge(count: Int) {
        guard let button = statusItem?.button else { return }
        
        if count > 0 {
            button.title = " \(count)"
        } else {
            button.title = ""
        }
    }
}

// MARK: - Disk Space Info

struct DiskSpaceInfo {
    let totalSpace: Int64
    let freeSpace: Int64
    let usedSpace: Int64
    
    var usedPercentage: Int {
        guard totalSpace > 0 else { return 0 }
        return Int((Double(usedSpace) / Double(totalSpace)) * 100)
    }
    
    static func current() -> DiskSpaceInfo? {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(forPath: "/") else {
            return nil
        }
        
        guard let totalSpace = attributes[.systemSize] as? Int64,
              let freeSpace = attributes[.systemFreeSize] as? Int64 else {
            return nil
        }
        
        let usedSpace = totalSpace - freeSpace
        
        return DiskSpaceInfo(
            totalSpace: totalSpace,
            freeSpace: freeSpace,
            usedSpace: usedSpace
        )
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let performQuickScan = Notification.Name("performQuickScan")
    static let openPreferences = Notification.Name("openPreferences")
}
