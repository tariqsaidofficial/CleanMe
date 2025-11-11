import SwiftUI

struct ScanView: View {
    @EnvironmentObject var scanEngine: ScanEngine
    @EnvironmentObject var appSettings: AppSettings
    @State private var selectedScans: Set<ScanType> = [.cache, .logs, .temp]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Recommended Scans Section
                recommendedSection
                
                // All Scan Types Section
                allScansSection
                
                // Statistics
                if !scanEngine.scanResults.isEmpty {
                    statisticsSection
                }
                
                // Start Scan Button
                startScanButton
            }
            .padding(24)
        }
        .navigationTitle("System Scan")
    }
    
    // MARK: - Recommended Section
    private var recommendedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text("Recommended Scans")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ScanCard(
                    type: .cache,
                    isSelected: selectedScans.contains(.cache),
                    isRecommended: true
                ) {
                    toggleScan(.cache)
                }
                
                ScanCard(
                    type: .logs,
                    isSelected: selectedScans.contains(.logs),
                    isRecommended: true
                ) {
                    toggleScan(.logs)
                }
                
                ScanCard(
                    type: .temp,
                    isSelected: selectedScans.contains(.temp),
                    isRecommended: true
                ) {
                    toggleScan(.temp)
                }
            }
        }
    }
    
    // MARK: - All Scans Section
    private var allScansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.blue)
                Text("All Scan Types")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Select All") {
                    selectedScans = Set(ScanType.allCases)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                Button("None") {
                    selectedScans.removeAll()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ScanCard(
                    type: .downloads,
                    isSelected: selectedScans.contains(.downloads),
                    isRecommended: false
                ) {
                    toggleScan(.downloads)
                }
                
                ScanCard(
                    type: .duplicates,
                    isSelected: selectedScans.contains(.duplicates),
                    isRecommended: false
                ) {
                    toggleScan(.duplicates)
                }
                
                ScanCard(
                    type: .largeFiles,
                    isSelected: selectedScans.contains(.largeFiles),
                    isRecommended: false
                ) {
                    toggleScan(.largeFiles)
                }
                
                ScanCard(
                    type: .emptyFolders,
                    isSelected: selectedScans.contains(.emptyFolders),
                    isRecommended: false
                ) {
                    toggleScan(.emptyFolders)
                }
                
                ScanCard(
                    type: .trash,
                    isSelected: selectedScans.contains(.trash),
                    isRecommended: false
                ) {
                    toggleScan(.trash)
                }
            }
        }
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                StatCard(
                    icon: "doc.fill",
                    value: "\(scanEngine.scanResults.count)",
                    label: "Files Found"
                )
                
                StatCard(
                    icon: "internaldrive.fill",
                    value: formatBytes(scanEngine.totalSize),
                    label: "Total Size"
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(selectedScans.count)",
                    label: "Selected"
                )
            }
        }
    }
    
    // MARK: - Start Scan Button
    private var startScanButton: some View {
        VStack(spacing: 12) {
            if scanEngine.isScanning {
                VStack(spacing: 12) {
                    HStack {
                        SwiftUI.ProgressView()
                            .scaleEffect(0.9)
                        Text("Scanning...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.15), radius: 8, y: 4)
                }
            } else {
                Button {
                    startScan()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 32))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("START SYSTEM SCAN")
                                .font(.headline)
                                .fontWeight(.bold)
                            Text("Ready to scan \(selectedScans.count) location(s)")
                                .font(.caption)
                                .opacity(0.8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [.blue, Color(red: 0.3, green: 0.5, blue: 0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.15), radius: 12, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(selectedScans.isEmpty)
            }
        }
    }
    
    // MARK: - Helper Functions
    private func toggleScan(_ type: ScanType) {
        if selectedScans.contains(type) {
            selectedScans.remove(type)
        } else {
            selectedScans.insert(type)
        }
    }
    
    private func startScan() {
        Task {
            await scanEngine.performFullScan { progress, message in
                // Progress updates handled by ScanEngine
            }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Scan Type Enum
enum ScanType: String, CaseIterable, Identifiable {
    case cache = "Cache Files"
    case logs = "Log Files"
    case temp = "Temporary Files"
    case downloads = "Downloads"
    case duplicates = "Duplicates"
    case largeFiles = "Large Files"
    case emptyFolders = "Empty Folders"
    case trash = "Trash Bin"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .cache: return "folder.fill"
        case .logs: return "doc.text.fill"
        case .temp: return "clock.fill"
        case .downloads: return "arrow.down.circle.fill"
        case .duplicates: return "doc.on.doc.fill"
        case .largeFiles: return "archivebox.fill"
        case .emptyFolders: return "folder.badge.minus"
        case .trash: return "trash.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .cache, .logs, .temp:
            return .blue // System files - Blue
        case .downloads, .duplicates, .largeFiles, .emptyFolders, .trash:
            return Color(red: 0.8, green: 0.3, blue: 0.3) // User files - Maroon
        }
    }
    
    var description: String {
        switch self {
        case .cache: return "App caches"
        case .logs: return "System logs"
        case .temp: return "Temporary"
        case .downloads: return "Downloads"
        case .duplicates: return "Find dupes"
        case .largeFiles: return "Large files"
        case .emptyFolders: return "Empty dirs"
        case .trash: return "Trash bin"
        }
    }
    
    var isSystemFile: Bool {
        switch self {
        case .cache, .logs, .temp:
            return true
        default:
            return false
        }
    }
}

// MARK: - Scan Card
struct ScanCard: View {
    let type: ScanType
    let isSelected: Bool
    let isRecommended: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(type.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(type.color)
                }
                
                // Title
                Text(type.rawValue)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Description
                Text(type.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // Selection indicator
                HStack(spacing: 4) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundColor(isSelected ? .green : .secondary)
                    
                    if isRecommended {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(width: 140, height: 120)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? type.color.opacity(0.2) : Color.black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.controlBackgroundColor))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
            .environmentObject(ScanEngine())
            .environmentObject(AppSettings())
            .frame(width: 900, height: 700)
    }
}
