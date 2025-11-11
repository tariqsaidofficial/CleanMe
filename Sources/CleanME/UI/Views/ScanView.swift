import SwiftUI

struct ScanView: View {
    @EnvironmentObject var scanEngine: ScanEngine
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedScans: Set<ScanType> = [.cache, .logs, .temp]
    @State private var scanProgress: Double = 0.0
    @State private var previousProgress: Double = 0.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Smart Recommendation with Progress
                HStack(spacing: 16) {
                    smartRecommendationCard
                    
                    // Progress Visualization (compact)
                    if scanEngine.isScanning {
                        compactProgressView
                    }
                }
                
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
        .frame(minWidth: 600, idealWidth: 900, maxWidth: .infinity)
        .navigationTitle("System Scan")
        .onChange(of: scanProgress) { newValue in
            if newValue == 1.0 && previousProgress < 1.0 {
                FeedbackManager.shared.success()
            }
            previousProgress = newValue
        }
    }
    
    // MARK: - Smart Recommendation Card
    private var smartRecommendationCard: some View {
        let recommendation = SystemAnalyzer.shared.getSmartRecommendation()
        let info = SystemAnalyzer.shared.getSystemDriveInfo()
        
        return HStack(spacing: 16) {
            Image(systemName: "chart.pie.fill")
                .font(.system(size: 32))
                .foregroundColor(themeManager.current.accentColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("System Status")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(recommendation)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let info = info {
                    Text("\(SystemAnalyzer.shared.formatBytes(info.availableSpace)) available of \(SystemAnalyzer.shared.formatBytes(info.totalSpace))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    // MARK: - Compact Progress View
    private var compactProgressView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: scanProgress)
                    .stroke(
                        themeManager.current.accentColor,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: scanProgress)
                
                Text("\(Int(scanProgress * 100))%")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            Text("Scanning...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    // MARK: - Progress Visualization
    private var progressVisualization: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: scanProgress)
                    .stroke(
                        themeManager.current.accentColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: scanProgress)
                
                VStack(spacing: 4) {
                    Text("\(Int(scanProgress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Scanning...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Finding files to clean")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Material.ultraThin)
        .cornerRadius(16)
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
                    HStack(spacing: 10) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 20))
                        Text("Start Scan")
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundColor(.white)
                    .background(
                        LinearGradient(
                            colors: [.blue, Color(red: 0.3, green: 0.5, blue: 0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.2), radius: 8, y: 2)
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
        scanProgress = 0.0
        Task {
            await scanEngine.performFullScan { progress, message in
                await MainActor.run {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                        scanProgress = progress
                    }
                    
                    if progress == 1.0 {
                        FeedbackManager.combinedFeedback(haptic: .levelChange, flash: true)
                    }
                }
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
            VStack(spacing: 8) {
                // Icon
                ZStack {
                    Circle()
                        .fill(type.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(type.color)
                }
                
                // Title
                Text(type.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Selection indicator
                HStack(spacing: 4) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 12))
                        .foregroundColor(isSelected ? .green : .secondary)
                    
                    if isRecommended {
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(width: 110, height: 100)
            .padding(10)
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
