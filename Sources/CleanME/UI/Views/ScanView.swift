import SwiftUI

struct ScanView: View {
    @EnvironmentObject var scanEngine: ScanEngine
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedScans: Set<ScanType> = [.cache, .logs, .temp]
    @State private var scanProgress: Double = 0.0
    @State private var previousProgress: Double = 0.0
    @State private var scanMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section: Storage Bar + Quick Stats
            VStack(spacing: 16) {
                storageBar
                quickStatsRow
            }
            .padding(20)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Main Content: Scan Cards (No Scroll)
            VStack(spacing: 20) {
                // Scan Types Grid
                scanTypesGrid
                
                Spacer(minLength: 0)
                
                // Bottom: Action Button
                actionButton
            }
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: scanProgress) { newValue in
            if newValue == 1.0 && previousProgress < 1.0 {
                FeedbackManager.shared.success()
            }
            previousProgress = newValue
        }
    }
    
    // MARK: - Storage Bar
    private var storageBar: some View {
        let info = SystemAnalyzer.shared.getSystemDriveInfo()
        let usedPercentage = info?.usedPercentage ?? 0
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "internaldrive.fill")
                    .foregroundColor(.blue)
                Text("System Storage")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if let info = info {
                    Text("\(info.availableSpace.formatBytes()) free")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: usedPercentage > 85 ? [.red, .orange] : usedPercentage > 70 ? [.orange, .yellow] : [.blue, .cyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (usedPercentage / 100), height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text("\(Int(usedPercentage))% used")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let info = info {
                    Text("\(info.totalSpace.formatBytes()) total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Quick Stats Row
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            if scanEngine.isScanning {
                // Scanning Progress
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                            .frame(width: 40, height: 40)
                        
                        Circle()
                            .trim(from: 0, to: scanProgress)
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: scanProgress)
                        
                        Text("\(Int(scanProgress * 100))")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Scanning...")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(scanMessage.isEmpty ? "Analyzing files" : scanMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if !scanEngine.scanResults.isEmpty {
                // Results Stats
                quickStatCard(icon: "doc.fill", value: "\(scanEngine.scanResults.count)", label: "Files")
                quickStatCard(icon: "internaldrive.fill", value: scanEngine.totalSize.formatBytes(), label: "Size")
                quickStatCard(icon: "checkmark.circle.fill", value: "\(selectedScans.count)", label: "Selected")
            } else {
                // Initial State
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.blue)
                    Text("Select scan types and start cleaning")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private func quickStatCard(icon: String, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
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
    
    // MARK: - Scan Types Grid
    private var scanTypesGrid: some View {
        VStack(spacing: 16) {
            // Header with actions
            HStack {
                Text("Scan Types")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("All") {
                    selectedScans = Set(ScanType.allCases)
                    FeedbackManager.shared.selection()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("None") {
                    selectedScans.removeAll()
                    FeedbackManager.shared.selection()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            
            // Grid: 4 columns for better space usage
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(ScanType.allCases) { type in
                    CompactScanCard(
                        type: type,
                        isSelected: selectedScans.contains(type)
                    ) {
                        toggleScan(type)
                        FeedbackManager.shared.selection()
                    }
                }
            }
        }
    }
    
    
    
    // MARK: - Action Button
    private var actionButton: some View {
        Button {
            startScan()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: scanEngine.isScanning ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title3)
                Text(scanEngine.isScanning ? "Scanning..." : "Start Scan")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: scanEngine.isScanning ? [.orange, .red] : [.blue, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: (scanEngine.isScanning ? Color.orange : Color.blue).opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(selectedScans.isEmpty && !scanEngine.isScanning)
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
        scanMessage = ""
        
        // Convert selected scan types to strings
        let selectedTypeNames = Set(selectedScans.map { $0.rawValue })
        
        Task {
            await scanEngine.performFullScan(selectedTypes: selectedTypeNames) { progress, message in
                await MainActor.run {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                        scanProgress = progress
                        scanMessage = message
                    }
                    
                    if progress == 1.0 {
                        FeedbackManager.combinedFeedback(haptic: .levelChange, flash: true)
                    }
                }
            }
        }
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

// MARK: - Compact Scan Card
struct CompactScanCard: View {
    let type: ScanType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon
                ZStack {
                    Circle()
                        .fill(type.color.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 16))
                        .foregroundColor(type.color)
                }
                
                // Title
                Text(type.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .green : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? type.color : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? type.color.opacity(0.2) : Color.black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
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
