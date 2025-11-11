import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appSettings: AppSettings
    @StateObject private var scanEngine = ScanEngine()
    @State private var selection: NavigationItem = .scan
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            sidebarView
            mainContentView
        }
        .navigationTitle("")
        .frame(minWidth: 900, minHeight: 600)
    }
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            // Logo Header
            logoHeaderView
            
            Divider()
            
            navigationList
            
            Spacer()
            
            footerView
        }
        .frame(width: 240)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 16, y: 4)
    }
    
    private var logoHeaderView: some View {
        HStack(spacing: 12) {
            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            
            Text("CleanME")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Search...", text: $searchText)
                .textFieldStyle(.plain)
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
        .padding()
    }
    
    private var navigationList: some View {
        List {
            Section("🧹 Main Tools") {
                sidebarButton(item: .scan, label: "System Scan", icon: "magnifyingglass.circle.fill")
                sidebarButton(item: .results, label: "Results", icon: "chart.bar.doc.horizontal.fill")
                
                if scanEngine.isScanning {
                    HStack {
                        SwiftUI.ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 16, height: 16)
                        Text("Scanning...")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("⚙️ Configuration") {
                sidebarButton(item: .settings, label: "Settings", icon: "gearshape.fill")
                sidebarButton(item: .about, label: "About", icon: "info.circle.fill")
            }
        }
        .listStyle(.sidebar)
    }
    
    private func sidebarButton(item: NavigationItem, label: String, icon: String) -> some View {
        Button(action: { selection = item }) {
            Label(label, systemImage: icon)
        }
        .buttonStyle(.plain)
    }
    
    private var footerView: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("CleanME")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text(Bundle.main.appVersion)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        }
    }
    
    private var mainContentView: some View {
        Group {
            switch selection {
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
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Navigation Items
enum NavigationItem: Hashable, CaseIterable {
    case scan
    case results
    case settings
    case about
    
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

// MARK: - Welcome View (saved for future use)
/*
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 72))
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
            
            Text("Welcome to CleanME")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your macOS System Cleaner")
                .font(.title3)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "trash.fill", title: "Clean Junk Files", description: "Remove cache, logs, and temporary files")
                FeatureRow(icon: "arrow.down.doc.fill", title: "Manage Downloads", description: "Find and delete old downloads")
                FeatureRow(icon: "doc.on.doc.fill", title: "Find Duplicates", description: "Locate and remove duplicate files")
                FeatureRow(icon: "shield.checkmark.fill", title: "Safe & Secure", description: "Protected files are never touched")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            .cornerRadius(12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
*/

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppSettings())
    }
}

