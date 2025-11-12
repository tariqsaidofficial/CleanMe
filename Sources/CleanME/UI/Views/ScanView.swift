import SwiftUI

struct ScanView: View {
    @EnvironmentObject var scanEngine: ScanEngine
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedScans: Set<ScanType> = [.cache, .logs, .temp]
    @State private var scanProgress: Double = 0.0
    @State private var previousProgress: Double = 0.0
    @State private var scanMessage: String = ""
    @State private var scanError: String? = nil
    @State private var hoveredCard: String? = nil
    @State private var hoveredButton: String? = nil
    
    // Callback for navigation
    var onScanComplete: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            // Dynamic Background with Mesh Gradient
            backgroundGradient
            
            VStack(spacing: 0) {
                // Modern Header
                modernHeaderView
                
                // Modern Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Modern Storage Section
                        modernStorageSection
                        
                        // Modern Scan Types Section
                        modernScanTypesSection
                        
                        // Error Handling Section
                        if let error = scanError {
                            modernErrorSection(error: error)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Space for floating button
                }
                
                Spacer()
            }
            
            // Floating Action Button
            VStack {
                Spacer()
                modernFloatingActionButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .onChange(of: scanProgress) { newValue in
            if newValue == 1.0 && previousProgress < 1.0 {
                FeedbackManager.shared.success()
                scanError = nil // Clear any previous errors on success
            }
            previousProgress = newValue
        }
    }
    
    // MARK: - Dynamic Background
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated mesh overlay based on scan state
            RadialGradient(
                colors: [
                    scanEngine.isScanning ? Color.orange.opacity(0.15) : Color.blue.opacity(0.15),
                    scanEngine.isScanning ? Color.red.opacity(0.08) : Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .animation(.easeInOut(duration: 1.2), value: scanEngine.isScanning)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Modern Header View
    private var modernHeaderView: some View {
        VStack(spacing: 16) {
            // Header Title with Logo
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        AppLogoView(size: 32)
                        
                        Text("System Scan")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: AppColors.primaryGradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundStyle(AppColors.primaryLightBlue)
                    }
                    
                    Text(scanEngine.isScanning ? "Scanning in progress..." : "Select scan types and start cleaning")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Scan Progress Indicator
                if scanEngine.isScanning {
                    modernProgressIndicator
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Modern Progress Indicator
    private var modernProgressIndicator: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                .frame(width: 40, height: 40)
            
            Circle()
                .trim(from: 0, to: scanProgress)
                .stroke(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: scanProgress)
            
            Text("\(Int(scanProgress * 100))")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
        }
    }
    
    // MARK: - Modern Storage Section
    private var modernStorageSection: some View {
        let info = SystemAnalyzer.shared.getSystemDriveInfo()
        let usedPercentage = info?.usedPercentage ?? 0
        
        return VStack(spacing: 16) {
            // Section Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.2), Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.1)],
                                center: .center,
                                startRadius: 15,
                                endRadius: 30
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "internaldrive.fill")
                        .font(.system(size: 18, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("System Storage")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    if let info = info {
                        Text("\(info.availableSpace.formatBytes()) free of \(info.totalSpace.formatBytes())")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                Text("\(Int(usedPercentage))% used")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(usedPercentage > 85 ? .red : usedPercentage > 70 ? .orange : .blue)
            }
            
            // Modern Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.regularMaterial)
                        .frame(height: 16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: usedPercentage > 85 ? [.red, .orange] : 
                                        usedPercentage > 70 ? [.orange, .yellow] : 
                                        [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (usedPercentage / 100), height: 16)
                        .shadow(color: (usedPercentage > 85 ? Color.red : usedPercentage > 70 ? Color.orange : Color.blue).opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 16)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Storage Bar (Old)
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
    
    // MARK: - Modern Scan Types Section
    private var modernScanTypesSection: some View {
        VStack(spacing: 20) {
            // Section Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.2), Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.1)],
                                center: .center,
                                startRadius: 15,
                                endRadius: 30
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Scan Types")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("\(selectedScans.count) of \(ScanType.allCases.count) selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Quick Actions
                HStack(spacing: 8) {
                    modernQuickActionButton(title: "All", action: selectAll)
                    modernQuickActionButton(title: "None", action: selectNone)
                }
            }
            
            // Modern Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 16) {
                ForEach(ScanType.allCases) { type in
                    ModernScanCard(
                        type: type,
                        isSelected: selectedScans.contains(type),
                        isHovered: hoveredCard == type.id
                    ) {
                        toggleScan(type)
                        FeedbackManager.shared.selection()
                    }
                    .onHover { isHovered in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            hoveredCard = isHovered ? type.id : nil
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Modern Quick Action Button
    private func modernQuickActionButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                .foregroundStyle(.blue)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Modern Error Section
    private func modernErrorSection(error: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.red.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.red)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Scan Error")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button("Retry") {
                scanError = nil
                startScan()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding(20)
        .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Modern Floating Action Button
    private var modernFloatingActionButton: some View {
        Button(action: {
            if scanEngine.isScanning {
                scanEngine.stopScan()
            } else {
                startScan()
            }
        }) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: scanEngine.isScanning ? "stop.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .scaleEffect(scanEngine.isScanning ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: scanEngine.isScanning)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(scanEngine.isScanning ? "Stop Scan" : "Start Scan")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    if scanEngine.isScanning {
                        Text(scanMessage.isEmpty ? "Scanning..." : scanMessage)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(1)
                    } else {
                        Text("\(selectedScans.count) types selected")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: scanEngine.isScanning ? [.orange, .red] : [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: (scanEngine.isScanning ? Color.orange : Color.blue).opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(hoveredButton == "scan" ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(selectedScans.isEmpty && !scanEngine.isScanning)
        .opacity(selectedScans.isEmpty && !scanEngine.isScanning ? 0.6 : 1.0)
        .onHover { isHovered in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                hoveredButton = isHovered ? "scan" : nil
            }
        }
    }
    
    // MARK: - Helper Functions
    private func selectAll() {
        selectedScans = Set(ScanType.allCases)
        FeedbackManager.shared.selection()
    }
    
    private func selectNone() {
        selectedScans.removeAll()
        FeedbackManager.shared.selection()
    }
    
    // MARK: - Scan Types Grid (Old)
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
        scanError = nil
        
        // Validate selection
        guard !selectedScans.isEmpty else {
            scanError = "Please select at least one scan type before starting."
            return
        }
        
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
                        
                        // Auto-navigate to Results after scan completion
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            onScanComplete?()
                        }
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
    
    var gradientColors: [Color] {
        switch self {
        case .cache, .logs, .temp:
            return [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)] // System files - Blue gradient
        case .downloads, .duplicates, .largeFiles, .emptyFolders, .trash:
            return [Color(red: 0.8, green: 0.2, blue: 0.3), Color(red: 0.6, green: 0.1, blue: 0.2)] // User files - Maroon gradient
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

// MARK: - Modern Scan Card
struct ModernScanCard: View {
    let type: ScanType
    let isSelected: Bool
    let isHovered: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icon with glow effect
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: type.gradientColors.map { $0.opacity(isSelected ? 0.3 : 0.1) },
                                center: .center,
                                startRadius: 15,
                                endRadius: 30
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 20, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: type.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
                }
                
                VStack(spacing: 4) {
                    Text(type.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(type.description)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .green : .secondary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 120)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? 
                        LinearGradient(
                            colors: type.gradientColors.map { $0.opacity(0.6) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [.clear, .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .shadow(color: isSelected ? type.gradientColors[0].opacity(0.3) : .black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Compact Scan Card (Old)
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
