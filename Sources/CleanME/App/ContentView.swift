import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var scanEngine = ScanEngine()
    @State private var selection: Folder? = .scan
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showShortcuts = false
    @State private var isNavigating = false
    
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
            .frame(minWidth: 240)
            .background(
                ZStack {
                    // Dynamic background gradient
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.05),
                            Color.cyan.opacity(0.02),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    // Subtle mesh overlay
                    RadialGradient(
                        colors: [
                            sidebarGradientColors[0].opacity(0.08),
                            sidebarGradientColors[1].opacity(0.04),
                            Color.clear
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
                FolderDetailView(folder: folder)
                    .environmentObject(scanEngine)
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
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.charactersIgnoringModifiers == "/" {
                    showShortcuts.toggle()
                    return nil
                }
                return event
            }
        }
    }
    
    
    // MARK: - Unified Color Scheme
    private var primaryGradientColors: [Color] {
        [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)] // Blue to light blue
    }
    
    private var accentGradientColors: [Color] {
        [Color(red: 0.8, green: 0.2, blue: 0.3), Color(red: 0.6, green: 0.1, blue: 0.2)] // Maroon red
    }
    
    private var sidebarGradientColors: [Color] {
        primaryGradientColors
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
                                colors: sidebarGradientColors,
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
            navigateToFolder(folder)
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
                        .scaleEffect(isNavigating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isNavigating)
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
        .disabled(isNavigating) // Prevent multiple taps
        .opacity(isNavigating && selection != folder ? 0.6 : 1.0)
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
    
    // MARK: - Navigation Functions
    private func navigateToFolder(_ folder: Folder) {
        // Prevent multiple rapid taps
        guard !isNavigating else { return }
        
        // If already selected, don't do anything
        guard selection != folder else { return }
        
        isNavigating = true
        
        // Provide immediate haptic feedback
        FeedbackManager.shared.selection()
        
        // Update selection immediately for instant visual feedback
        selection = folder
        
        // Smooth animation for visual elements
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            // This will trigger UI updates
        }
        
        // Reset navigation flag after a shorter delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isNavigating = false
        }
    }
}


// MARK: - Folder Detail View
struct FolderDetailView: View {
    let folder: Folder
    @EnvironmentObject var scanEngine: ScanEngine
    
    var body: some View {
        Group {
            switch folder {
            case .scan:
                ScanView()
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        case .scan: return [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)]
        case .results: return [Color(red: 0.8, green: 0.2, blue: 0.3), Color(red: 0.6, green: 0.1, blue: 0.2)]
        case .settings: return [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)]
        case .about: return [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)]
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

