import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var scanEngine = ScanEngine()
    @State private var selection: Folder? = .scan
    @State private var searchText = ""
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showShortcuts = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack(spacing: 0) {
                // Logo Header
                HStack(spacing: 12) {
                    // Load logo from bundle
                    if let resourcePath = Bundle.main.resourcePath,
                       let logoImage = NSImage(contentsOfFile: resourcePath + "/CleanME_CleanME.bundle/logo.png") {
                        Image(nsImage: logoImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    Text("CleanME")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding()
                
                Divider()
                
                List(Folder.allCases, selection: $selection) { folder in
                    Label(folder.title, systemImage: folder.icon)
                        .tag(folder)
                }
                .listStyle(.sidebar)
            }
            .frame(minWidth: 220)
            .background(Material.ultraThin)
            .animation(.easeInOut(duration: 0.25), value: selection)
        } detail: {
            if let folder = selection {
                FolderDetailView(folder: folder)
                    .environmentObject(scanEngine)
                    .accentColor(themeManager.current.accentColor)
                    .preferredColorScheme(themeManager.current.colorScheme)
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.25), value: folder)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button(action: toggleSidebar) {
                                Image(systemName: "sidebar.leading")
                            }
                        }
                        
                        ToolbarItemGroup {
                            Button(action: startScan) {
                                Image(systemName: "play.circle")
                            }
                            .help("Start Scan")
                            
                            Button(action: deleteSelected) {
                                Image(systemName: "trash")
                            }
                            .help("Delete Selected")
                            .disabled(scanEngine.scanResults.isEmpty)
                            
                            Button(action: exportResults) {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .help("Export Results")
                            .disabled(scanEngine.scanResults.isEmpty)
                            
                            Spacer()
                            
                            SearchField(text: $searchText)
                        }
                    }
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
    
    private func toggleSidebar() {
        FeedbackManager.shared.selection()
        columnVisibility = columnVisibility == .all ? .detailOnly : .all
    }
    
    private func startScan() {
        FeedbackManager.shared.trigger(.levelChange)
        Task {
            await scanEngine.performFullScan { _, _ in }
        }
    }
    
    private func deleteSelected() {
        FeedbackManager.shared.delete()
        // Handle delete action
    }
    
    private func exportResults() {
        FeedbackManager.shared.success()
        // Handle export action
    }
}

// MARK: - Search Field
struct SearchField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search...", text: $text)
                .textFieldStyle(.plain)
                .frame(width: 200)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
}

// MARK: - Folder Detail View
struct FolderDetailView: View {
    let folder: Folder
    @EnvironmentObject var scanEngine: ScanEngine
    @State private var sortOrder: [KeyPathComparator<FileItem>] = [
        .init(\.dateModified, order: .reverse)
    ]
    @State private var selection: Set<FileItem.ID> = []
    
    var body: some View {
        Group {
            switch folder {
            case .scan:
                ScanView()
                    .environmentObject(scanEngine)
            case .results:
                fileTableView
            case .settings:
                SettingsView()
            case .about:
                AboutView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var fileTableView: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 350, maximum: 500), spacing: 12)],
                alignment: .leading,
                spacing: 12
            ) {
                ForEach(scanEngine.fileItems) { item in
                    ResultCard(
                        item: item,
                        isSelected: selection.contains(item.id),
                        onToggle: {
                            if selection.contains(item.id) {
                                selection.remove(item.id)
                            } else {
                                selection.insert(item.id)
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: scanEngine.fileItems)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Material.ultraThin)
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
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
    }
}

