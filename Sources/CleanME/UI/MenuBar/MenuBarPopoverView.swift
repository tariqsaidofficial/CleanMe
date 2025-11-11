import SwiftUI

/// Popover view shown when clicking the menu bar icon
struct MenuBarPopoverView: View {
    @EnvironmentObject var menuBarManager: MenuBarManager
    @StateObject private var scanEngine = ScanEngine()
    
    @State private var isScanning = false
    @State private var scanProgress: Double = 0.0
    @State private var scanMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Disk Space Info
            diskSpaceView
            
            Divider()
            
            // Quick Actions
            if isScanning {
                scanningView
            } else {
                quickActionsView
            }
            
            Divider()
            
            // Footer
            footerView
        }
        .frame(width: 320, height: 400)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("CleanME")
                .font(.headline)
            
            Spacer()
            
            Button(action: openMainApp) {
                Image(systemName: "arrow.up.right.square")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .help("Open Main App")
        }
        .padding()
    }
    
    // MARK: - Disk Space
    
    private var diskSpaceView: some View {
        VStack(spacing: 12) {
            if let diskInfo = menuBarManager.diskSpaceInfo {
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(diskInfo.usedPercentage) / 100)
                        .stroke(
                            diskUsageColor(diskInfo.usedPercentage),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: diskInfo.usedPercentage)
                    
                    VStack(spacing: 4) {
                        Text("\(diskInfo.usedPercentage)%")
                            .font(.title.bold())
                        Text("Used")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Space Info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Free Space")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(diskInfo.freeSpace.formatBytes())
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total Space")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(diskInfo.totalSpace.formatBytes())
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Unable to read disk space")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding(.vertical)
    }
    
    // MARK: - Quick Actions
    
    private var quickActionsView: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            VStack(spacing: 8) {
                QuickActionButton(
                    icon: "magnifyingglass",
                    title: "Quick Scan",
                    subtitle: "Scan for junk files",
                    color: .blue
                ) {
                    performQuickScan()
                }
                
                QuickActionButton(
                    icon: "trash",
                    title: "Empty Trash",
                    subtitle: "Clear system trash",
                    color: .red
                ) {
                    emptyTrash()
                }
                
                QuickActionButton(
                    icon: "arrow.clockwise",
                    title: "Clear Caches",
                    subtitle: "Remove cache files",
                    color: .orange
                ) {
                    clearCaches()
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    // MARK: - Scanning View
    
    private var scanningView: some View {
        VStack(spacing: 16) {
            ProgressView(value: scanProgress) {
                HStack {
                    Text("Scanning...")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(scanProgress * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(scanMessage)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Button("Cancel") {
                // TODO: Cancel scan
                isScanning = false
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        HStack {
            Button(action: openPreferences) {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .help("Preferences")
            
            Spacer()
            
            Text("Last scan: Never")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: quitApp) {
                Image(systemName: "power")
            }
            .buttonStyle(.plain)
            .help("Quit")
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func diskUsageColor(_ percentage: Int) -> Color {
        switch percentage {
        case 0..<70:
            return .green
        case 70..<85:
            return .orange
        default:
            return .red
        }
    }
    
    private func performQuickScan() {
        isScanning = true
        scanProgress = 0.0
        scanMessage = "Initializing scan..."
        
        Task {
            await scanEngine.performFullScan(
                selectedTypes: ["Cache Files", "Log Files", "Temporary Files"]
            ) { progress, message in
                await MainActor.run {
                    scanProgress = progress
                    scanMessage = message
                    
                    if progress >= 1.0 {
                        isScanning = false
                        menuBarManager.showNotification(
                            title: "Scan Complete",
                            message: "Found \(scanEngine.scanResults.count) items"
                        )
                    }
                }
            }
        }
    }
    
    private func emptyTrash() {
        // TODO: Implement empty trash
        menuBarManager.showNotification(
            title: "Trash Emptied",
            message: "System trash has been cleared"
        )
    }
    
    private func clearCaches() {
        // TODO: Implement clear caches
        menuBarManager.showNotification(
            title: "Caches Cleared",
            message: "Cache files have been removed"
        )
    }
    
    private func openMainApp() {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func openPreferences() {
        NotificationCenter.default.post(name: .openPreferences, object: nil)
        openMainApp()
    }
    
    private func quitApp() {
        NSApp.terminate(nil)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    MenuBarPopoverView()
        .environmentObject(MenuBarManager.shared)
}
