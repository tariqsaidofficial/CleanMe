import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var scanEngine = ScanEngine()
    @State private var selection: Folder? = .scan
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showShortcuts = false
    
    // Keyboard shortcut states
    @State private var keyboardShortcutsEnabled = true
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack(spacing: 0) {
                // Modern Header with Glass Morphism
                modernSidebarHeader
                
                // Modern Navigation List
                modernNavigationList
                
                Spacer()
                
                // Modern Footer
                modernSidebarFooter
            }
            .background(
                ZStack {
                    // Dynamic background gradient
                    LinearGradient(
                        colors: [
                            AppColors.primaryBlue.opacity(0.05),
                            AppColors.primaryLightBlue.opacity(0.02),
                            AppColors.systemClear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle mesh overlay
                    RadialGradient(
                        colors: [
                            AppColors.primaryBlue.opacity(0.08),
                            AppColors.primaryLightBlue.opacity(0.04),
                            AppColors.systemClear
                        ],
                        center: .topTrailing,
                        startRadius: 50,
                        endRadius: 200
                    )
                    .animation(.easeInOut(duration: 0.6), value: selection)
                }
                .background(.ultraThinMaterial)
            )
            .animation(.easeInOut(duration: 0.3), value: selection)
        } detail: {
            if let folder = selection {
                Group {
                    switch folder {
                    case .scan:
                        ScanView(onScanComplete: {
                            // Auto-navigate to Results when scan completes
                            withAnimation(.easeInOut(duration: 0.3)) {
                                selection = .results
                            }
                            FeedbackManager.shared.success()
                        })
                        .environmentObject(scanEngine)
                    case .results:
                        ResultsView()
                            .environmentObject(scanEngine)
                    case .settings:
                        SettingsView()
                    case .about:
                        AboutView()
                    }
                }
                .accentColor(themeManager.current.accentColor)
                .preferredColorScheme(themeManager.current.colorScheme)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: folder)
                .id(folder.rawValue) // Force view refresh
            } else {
                PlaceholderView()
            }
        }
        .frame(minWidth: 900, idealWidth: 1200, maxWidth: .infinity, minHeight: 600, idealHeight: 800, maxHeight: .infinity)
        .overlay(
            ShortcutOverlayView()
                .opacity(showShortcuts ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: showShortcuts)
                .onTapGesture {
                    showShortcuts = false
                }
        )
        .onAppear {
            setupKeyboardShortcuts()
            setupMenuNotifications()
        }
        .background(
            // Hidden buttons for keyboard shortcuts
            VStack {
                Button("Start Scan Hidden") { handleStartScan() }
                    .keyboardShortcut("s", modifiers: .command)
                    .hidden()
                
                Button("Clean Selected Hidden") { handleCleanSelected() }
                    .keyboardShortcut("k", modifiers: .command)
                    .hidden()
                
                Button("Refresh Results Hidden") { handleRefreshResults() }
                    .keyboardShortcut("r", modifiers: .command)
                    .hidden()
                
                Button("Open Settings Hidden") { handleOpenSettings() }
                    .keyboardShortcut(",", modifiers: .command)
                    .hidden()
                
                Button("Select All Hidden") { handleSelectAll() }
                    .keyboardShortcut("a", modifiers: .command)
                    .hidden()
                
                Button("Show Shortcuts Hidden") { showShortcuts.toggle() }
                    .keyboardShortcut("/", modifiers: .command)
                    .hidden()
            }
        )
    }
    
    
    
    // MARK: - Modern Sidebar Header
    private var modernSidebarHeader: some View {
        VStack(spacing: 16) {
            // Logo and Title
            HStack(spacing: 12) {
                AppLogoView(size: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("CleanME")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: AppColors.primaryGradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Mac Optimizer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }
    
    // MARK: - Modern Navigation List
    private var modernNavigationList: some View {
        VStack(spacing: 8) {
            ForEach(Folder.allCases, id: \.self) { folder in
                modernNavigationItem(folder: folder)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 16)
    }
    
    // MARK: - Modern Navigation Item
    private func modernNavigationItem(folder: Folder) -> some View {
        Button(action: {
            // Direct navigation without delays
            FeedbackManager.shared.selection()
            selection = folder
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            selection == folder ?
                            RadialGradient(
                                colors: folder.gradientColors.map { $0.opacity(0.3) },
                                center: .center,
                                startRadius: 10,
                                endRadius: 20
                            ) :
                            RadialGradient(
                                colors: [.gray.opacity(0.1), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 20
                            )
                        )
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: folder.icon)
                        .font(.system(size: 16, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            selection == folder ?
                            LinearGradient(
                                colors: folder.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.secondary, .secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(folder.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(selection == folder ? .primary : .secondary)
                
                Spacer()
                
                if selection == folder {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: folder.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                selection == folder ?
                LinearGradient(
                    colors: folder.gradientColors.map { $0.opacity(0.1) },
                    startPoint: .leading,
                    endPoint: .trailing
                ) :
                LinearGradient(
                    colors: [.clear, .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .background(.regularMaterial.opacity(selection == folder ? 1.0 : 0.0), in: RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        selection == folder ?
                        LinearGradient(
                            colors: folder.gradientColors.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [.clear, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Modern Sidebar Footer
    private var modernSidebarFooter: some View {
        VStack(spacing: 12) {
            Divider()
                .opacity(0.5)
            
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version \(version)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "c.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Text("2025 CleanME")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .padding(.bottom, 12)
    }
    
    // MARK: - Keyboard Shortcuts Handlers
    
    private func setupKeyboardShortcuts() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            print("🔍 Key pressed: \(event.charactersIgnoringModifiers ?? "nil"), modifiers: \(event.modifierFlags)")
            
            guard event.modifierFlags.contains(.command) else { return event }
            guard self.keyboardShortcutsEnabled else { 
                print("❌ Keyboard shortcuts disabled")
                return event 
            }
            
            guard let chars = event.charactersIgnoringModifiers else { return event }
            
            print("✅ Processing command+\(chars)")
            
            DispatchQueue.main.async {
                switch chars {
                case "s":
                    print("🚀 Executing Start Scan")
                    self.handleStartScan()
                case "k":
                    print("🧹 Executing Clean Selected")
                    self.handleCleanSelected()
                case "r":
                    print("🔄 Executing Refresh Results")
                    self.handleRefreshResults()
                case ",":
                    print("⚙️ Executing Open Settings")
                    self.handleOpenSettings()
                case "/":
                    print("❓ Toggling Shortcuts")
                    self.showShortcuts.toggle()
                case "a":
                    print("✅ Executing Select All")
                    self.handleSelectAll()
                case "w":
                    print("❌ Executing Close Window")
                    self.handleCloseWindow()
                case "q":
                    print("🚪 Executing Quit App")
                    self.handleQuitApp()
                default:
                    print("❓ Unknown shortcut: \(chars)")
                }
            }
            
            return nil
        }
    }
    
    private func setupMenuNotifications() {
        NotificationCenter.default.addObserver(
            forName: .showShortcutsMenu,
            object: nil,
            queue: .main
        ) { _ in
            print("❓ Menu notification received - toggling shortcuts")
            showShortcuts.toggle()
        }
    }
    
    private func handleStartScan() {
        print("🚀🚀🚀 handleStartScan called from hidden button!")
        guard keyboardShortcutsEnabled else { 
            print("❌ Shortcuts disabled in handleStartScan")
            return 
        }
        
        print("📍 Current selection: \(selection?.rawValue ?? "nil")")
        
        // Navigate to scan view if not already there
        if selection != .scan {
            print("🔄 Navigating to scan view")
            withAnimation(.easeInOut(duration: 0.3)) {
                selection = .scan
            }
        }
        
        // Trigger scan start - we'll need to communicate with ScanView
        print("📡 Posting startScanShortcut notification")
        NotificationCenter.default.post(name: .startScanShortcut, object: nil)
        FeedbackManager.shared.selection()
        print("✅ handleStartScan completed")
    }
    
    private func handleCleanSelected() {
        guard keyboardShortcutsEnabled else { return }
        
        // Navigate to results view if not already there
        if selection != .results {
            withAnimation(.easeInOut(duration: 0.3)) {
                selection = .results
            }
        }
        
        // Trigger clean selected - communicate with ResultsView
        NotificationCenter.default.post(name: .cleanSelectedShortcut, object: nil)
        FeedbackManager.shared.selection()
    }
    
    private func handleRefreshResults() {
        guard keyboardShortcutsEnabled else { return }
        
        // Navigate to results view if not already there
        if selection != .results {
            withAnimation(.easeInOut(duration: 0.3)) {
                selection = .results
            }
        }
        
        // Trigger refresh - communicate with ResultsView
        NotificationCenter.default.post(name: .refreshResultsShortcut, object: nil)
        FeedbackManager.shared.selection()
    }
    
    private func handleOpenSettings() {
        guard keyboardShortcutsEnabled else { return }
        
        // Navigate to settings view
        withAnimation(.easeInOut(duration: 0.3)) {
            selection = .settings
        }
        FeedbackManager.shared.selection()
    }
    
    private func handleSelectAll() {
        guard keyboardShortcutsEnabled else { return }
        
        // Send notification based on current view
        switch selection {
        case .scan:
            NotificationCenter.default.post(name: .selectAllScanTypes, object: nil)
        case .results:
            NotificationCenter.default.post(name: .selectAllResults, object: nil)
        default:
            break
        }
        FeedbackManager.shared.selection()
    }
    
    private func handleCloseWindow() {
        guard keyboardShortcutsEnabled else { return }
        
        // Close current window
        if let window = NSApp.keyWindow {
            window.performClose(nil)
        }
    }
    
    private func handleQuitApp() {
        guard keyboardShortcutsEnabled else { return }
        
        // Quit application
        NSApp.terminate(nil)
    }
    
}



// MARK: - Placeholder View
struct PlaceholderView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            Text("Select a folder")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Folder Enum
enum Folder: String, CaseIterable, Identifiable {
    case scan
    case results
    case settings
    case about
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .scan: return "System Scan"
        case .results: return "Results"
        case .settings: return "Settings"
        case .about: return "About"
        }
    }
    
    var icon: String {
        switch self {
        case .scan: return "magnifyingglass.circle.fill"
        case .results: return "chart.bar.doc.horizontal.fill"
        case .settings: return "gearshape.fill"
        case .about: return "info.circle.fill"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .scan: return AppColors.primaryGradient
        case .results: return AppColors.accentGradient
        case .settings: return AppColors.primaryGradient
        case .about: return AppColors.primaryGradient
        }
    }
}



// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
    }
}

