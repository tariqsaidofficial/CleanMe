import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var scanEngine: ScanEngine
    @EnvironmentObject var appSettings: AppSettings
    @State private var selectedItems = Set<UUID>()
    @State private var isDeleting = false
    @State private var deletionProgress: Double = 0.0
    @State private var deletionMessage: String = ""
    @State private var showingDeletionConfirmation = false
    @State private var sortOrder: SortOrder = .size
    @State private var searchText = ""
    @State private var showingExportSheet = false
    @State private var showingToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    @State private var showSaveSheet = false
    @State private var showDraftAlert = false
    @State private var hoveredCard: String? = nil
    @State private var hoveredButton: String? = nil
    
    var filteredResults: [CleanupItem] {
        let filtered = scanEngine.scanResults.filter { item in
            searchText.isEmpty || item.fileName.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOrder {
        case .name:
            return filtered.sorted { $0.fileName < $1.fileName }
        case .size:
            return filtered.sorted { $0.fileSize > $1.fileSize }
        case .date:
            return filtered.sorted { $0.lastModified > $1.lastModified }
        case .type:
            return filtered.sorted { $0.fileType < $1.fileType }
        }
    }
    
    var selectedSize: Int64 {
        scanEngine.scanResults
            .filter { selectedItems.contains($0.id) }
            .reduce(0) { $0 + $1.fileSize }
    }
    
    var selectedCount: Int {
        selectedItems.count
    }
    
    var body: some View {
        ZStack {
            // Dynamic Background with Mesh Gradient
            backgroundGradient
            
            VStack(spacing: 0) {
                // Modern Header with Glass Morphism
                modernHeaderView
                
                // Modern Controls Section
                modernControlsView
                
                // Results Content Area
                Group {
                    if filteredResults.isEmpty {
                        modernEmptyStateView
                    } else {
                        modernResultsListView
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Modern Bottom Actions
                if !selectedItems.isEmpty && !isDeleting {
                    modernBottomActionsView
                }
                
                // Modern Progress Indicator
                if isDeleting {
                    modernDeletionProgressView
                }
            }
            
            // Modern Toast Overlay
            if showingToast {
                ModernToastView(message: toastMessage, type: toastType)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity, minHeight: 600, idealHeight: 800, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .navigationTitle("Scan Results")
        .sheet(isPresented: $showingDeletionConfirmation) {
            modernDeletionConfirmationSheet
        }
        .sheet(isPresented: $showingExportSheet) {
            modernExportSheet
        }
        .sheet(isPresented: $showSaveSheet) {
            SaveDocumentView(
                onSave: { name, location in
                    saveResults(name: name, location: location)
                },
                onDelete: {
                    clearResults()
                }
            )
        }
        .alert("Save scan results as a draft?", isPresented: $showDraftAlert) {
            Button("Save") { saveDraft() }
            Button("Don't Save", role: .destructive) { discardDraft() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This scan has not been saved and contains results. You can save it as a draft to review later.")
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
            
            // Animated mesh overlay based on results count
            RadialGradient(
                colors: [
                    selectedCount > 0 ? Color(red: 0.8, green: 0.2, blue: 0.3).opacity(0.15) : Color.blue.opacity(0.15),
                    selectedCount > 0 ? Color(red: 0.6, green: 0.1, blue: 0.2).opacity(0.08) : Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .animation(.easeInOut(duration: 1.2), value: selectedCount)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Modern Header View
    private var modernHeaderView: some View {
        VStack(spacing: 16) {
            // Header Title with Logo
            HStack(spacing: 12) {
                AppLogoView(size: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Scan Results")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("\(scanEngine.scanResults.count) files found • \(scanEngine.totalSize.formatBytes()) total")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Modern Stats Cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                modernStatsCard(
                    icon: "doc.fill",
                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                    title: "\(scanEngine.scanResults.count)",
                    subtitle: "Total Files",
                    description: "Files found in scan"
                )
                
                modernStatsCard(
                    icon: "checkmark.circle.fill",
                    gradient: selectedCount > 0 ? [.green, .mint] : [.gray, .secondary], // Keep success colors
                    title: "\(selectedCount)",
                    subtitle: "Selected",
                    description: selectedCount > 0 ? "Ready for cleanup" : "No files selected"
                )
                
                modernStatsCard(
                    icon: "internaldrive.fill",
                    gradient: selectedCount > 0 ? [Color(red: 0.8, green: 0.2, blue: 0.3), Color(red: 0.6, green: 0.1, blue: 0.2)] : [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                    title: (selectedCount > 0 ? selectedSize : scanEngine.totalSize).formatBytes(),
                    subtitle: selectedCount > 0 ? "Selected Size" : "Total Size",
                    description: selectedCount > 0 ? "Space to be freed" : "Total space used"
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Modern Stats Card
    private func modernStatsCard(icon: String, gradient: [Color], title: String, subtitle: String, description: String) -> some View {
        VStack(spacing: 12) {
            // Icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            center: .center,
                            startRadius: 15,
                            endRadius: 30
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(hoveredCard == subtitle ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: hoveredCard)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onHover { isHovered in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                hoveredCard = isHovered ? subtitle : nil
            }
        }
        .scaleEffect(hoveredCard == subtitle ? 1.02 : 1.0)
        .shadow(color: hoveredCard == subtitle ? gradient[0].opacity(0.2) : .clear, radius: 15, x: 0, y: 8)
    }
    
    // MARK: - Header View (Old)
    private var headerView: some View {
        HStack(spacing: 12) {
            // Total Files
            HStack(spacing: 8) {
                Image(systemName: "doc.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(scanEngine.scanResults.count)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Files")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Selected
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(selectedCount > 0 ? .green : .secondary)
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(selectedCount)")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("Selected")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Size
            HStack(spacing: 8) {
                Image(systemName: "internaldrive.fill")
                    .font(.title3)
                    .foregroundColor(selectedCount > 0 ? .orange : .blue)
                VStack(alignment: .leading, spacing: 0) {
                    Text((selectedCount > 0 ? selectedSize : scanEngine.totalSize).formatBytes())
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(selectedCount > 0 ? "Selected" : "Total")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Modern Controls View
    private var modernControlsView: some View {
        VStack(spacing: 16) {
            // Search and Sort Row
            HStack(spacing: 16) {
                // Modern Search Bar
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    TextField("Search files...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                
                // Modern Sort Menu
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button {
                            sortOrder = order
                        } label: {
                            HStack {
                                Text(order.displayName)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 14, weight: .medium))
                        Text("Sort")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Modern Action Buttons Row
            HStack(spacing: 12) {
                // Select All/Deselect All
                modernActionButton(
                    title: selectedCount == filteredResults.count ? "Deselect All" : "Select All",
                    icon: selectedCount == filteredResults.count ? "circle" : "checkmark.circle.fill",
                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                    action: toggleSelectAll,
                    id: "select_all"
                )
                
                Spacer()
                
                // Clean All
                modernActionButton(
                    title: "Clean All",
                    icon: "sparkles",
                    gradient: [.orange, .yellow], // Keep warning colors
                    action: {
                        selectedItems = Set(filteredResults.map { $0.id })
                        showingDeletionConfirmation = true
                    },
                    id: "clean_all",
                    isDisabled: filteredResults.isEmpty
                )
                
                // Delete Selected
                modernActionButton(
                    title: "Delete Selected",
                    icon: "trash",
                    gradient: [Color(red: 0.8, green: 0.2, blue: 0.3), Color(red: 0.6, green: 0.1, blue: 0.2)], // Maroon red for danger
                    action: { showingDeletionConfirmation = true },
                    id: "delete_selected",
                    isDisabled: selectedItems.isEmpty
                )
                
                // Export
                modernActionButton(
                    title: "Export",
                    icon: "square.and.arrow.up",
                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                    action: { showingExportSheet = true },
                    id: "export",
                    isDisabled: filteredResults.isEmpty
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Modern Action Button
    private func modernActionButton(title: String, icon: String, gradient: [Color], action: @escaping () -> Void, id: String, isDisabled: Bool = false) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .scaleEffect(hoveredButton == id ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hoveredButton)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if hoveredButton == id && !isDisabled {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: gradient.map { $0.opacity(0.2) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: gradient.map { $0.opacity(0.6) },
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
            .foregroundStyle(
                hoveredButton == id && !isDisabled ?
                LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [.primary, .primary], startPoint: .leading, endPoint: .trailing)
            )
            .scaleEffect(hoveredButton == id && !isDisabled ? 1.05 : 1.0)
            .shadow(color: hoveredButton == id && !isDisabled ? gradient[0].opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onHover { isHovered in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                hoveredButton = isHovered && !isDisabled ? id : nil
            }
        }
    }
    
    // MARK: - Controls View (Old)
    private var controlsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search files...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                
                // Sort menu
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button {
                            sortOrder = order
                        } label: {
                            HStack {
                                Text(order.displayName)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.arrow.down")
                        Text("Sort")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                // Select all / Deselect all
                Button(action: toggleSelectAll) {
                    HStack(spacing: 6) {
                        Image(systemName: selectedCount == filteredResults.count ? "circle" : "checkmark.circle.fill")
                        Text(selectedCount == filteredResults.count ? "Deselect All" : "Select All")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Spacer()
                
                // Clean All button
                Button(action: {
                    selectedItems = Set(filteredResults.map { $0.id })
                    showingDeletionConfirmation = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Clean All")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.small)
                .disabled(filteredResults.isEmpty)
                
                // Delete Selected button
                Button(action: { showingDeletionConfirmation = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                        Text("Delete Selected")
                    }
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .controlSize(.small)
                .disabled(selectedItems.isEmpty)
                
                // Export button
                Button(action: { showingExportSheet = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Export")
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .disabled(filteredResults.isEmpty)
            }
        }
        .padding(20)
    }
    
    // MARK: - Modern Results List View
    private var modernResultsListView: some View {
        List(filteredResults, selection: $selectedItems) { item in
            ModernFileItemRow(
                item: item,
                isSelected: selectedItems.contains(item.id)
            ) {
                toggleSelection(for: item.id)
            }
            .contextMenu {
                Button {
                    toggleSelection(for: item.id)
                } label: {
                    Label(selectedItems.contains(item.id) ? "Deselect" : "Select", 
                          systemImage: selectedItems.contains(item.id) ? "circle" : "checkmark.circle")
                }
                
                Button {
                    NSWorkspace.shared.selectFile(item.filePath, inFileViewerRootedAtPath: "")
                } label: {
                    Label("Reveal in Finder", systemImage: "folder")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    selectedItems = [item.id]
                    showingDeletionConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(.plain)
        .background(.clear)
    }
    
    // MARK: - Modern File Item Row
    struct ModernFileItemRow: View {
        let item: CleanupItem
        let isSelected: Bool
        let onToggle: () -> Void
        @State private var isHovered = false
        
        var body: some View {
            HStack(spacing: 12) {
                // Selection indicator
                Button(action: onToggle) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isSelected ? .green : .secondary)
                        .scaleEffect(isHovered ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
                }
                .buttonStyle(.plain)
                
                // File icon
                Image(systemName: fileIcon(for: String(describing: item.fileType)))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                
                // File info
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.fileName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(item.fileSize.formatBytes())
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .fontWeight(.medium)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(item.lastModified.formatted(.relative(presentation: .named)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(String(describing: item.fileType))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // File path
                Text(item.filePath)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
                    .frame(maxWidth: 200, alignment: .trailing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? .blue.opacity(0.1) : (isHovered ? .gray.opacity(0.05) : .clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? .blue.opacity(0.3) : .clear, lineWidth: 1)
            )
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
        }
        
        private func fileIcon(for type: String) -> String {
            switch type.lowercased() {
            case "cache": return "folder.fill"
            case "log": return "doc.text.fill"
            case "temp", "temporary": return "clock.fill"
            case "duplicate": return "doc.on.doc.fill"
            default: return "doc.fill"
            }
        }
    }
    
    // MARK: - Modern Empty State View
    private var modernEmptyStateView: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.blue.opacity(0.2), .cyan.opacity(0.1)],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: searchText.isEmpty ? "magnifyingglass.circle" : "doc.text.magnifyingglass")
                    .font(.system(size: 48, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 16) {
                Text(searchText.isEmpty ? "No Scan Results" : "No Results Found")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(searchText.isEmpty 
                    ? "No files have been scanned yet"
                    : "No files match your search criteria. Try a different search term.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // Warning Guide Card
            if searchText.isEmpty {
                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(.orange.opacity(0.2))
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Start System Scan")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Text("To perform a complete system scan, navigate to the System Scan tab and start the scanning process.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.orange)
                    }
                    .padding(20)
                    .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.orange.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Results List View (Old)
    private var resultsListView: some View {
        List(filteredResults, selection: $selectedItems) { item in
            FileItemRow(
                item: item,
                isSelected: selectedItems.contains(item.id)
            ) {
                toggleSelection(for: item.id)
            }
            .contextMenu {
                Button {
                    toggleSelection(for: item.id)
                } label: {
                    Label(selectedItems.contains(item.id) ? "Deselect" : "Select", 
                          systemImage: selectedItems.contains(item.id) ? "circle" : "checkmark.circle")
                }
                
                Button {
                    NSWorkspace.shared.selectFile(item.filePath, inFileViewerRootedAtPath: "")
                } label: {
                    Label("Reveal in Finder", systemImage: "folder")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    selectedItems = [item.id]
                    showingDeletionConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        EmptyStateView(
            icon: searchText.isEmpty ? "magnifyingglass.circle" : "doc.text.magnifyingglass",
            title: searchText.isEmpty ? "No Scan Results" : "No Results Found",
            message: searchText.isEmpty 
                ? "Run a system scan to find files you can clean up"
                : "No files match your search criteria. Try a different search term.",
            actionTitle: searchText.isEmpty ? "Start Scan" : nil,
            action: searchText.isEmpty ? {
                // Navigate to scan view
            } : nil
        )
    }
    
    // MARK: - Modern Bottom Actions View
    private var modernBottomActionsView: some View {
        HStack(spacing: 16) {
            modernActionButton(
                title: "Deselect All",
                icon: "circle",
                gradient: [.gray, .secondary],
                action: { selectedItems.removeAll() },
                id: "deselect_all"
            )
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(selectedCount) file(s) selected")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(selectedSize.formatBytes())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            modernActionButton(
                title: "Delete Selected",
                icon: "trash.fill",
                gradient: [.red, .pink],
                action: { showingDeletionConfirmation = true },
                id: "delete_selected_bottom"
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    // MARK: - Modern Deletion Progress View
    private var modernDeletionProgressView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.2), .red.opacity(0.1)],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 8) {
                    SwiftUI.ProgressView()
                        .scaleEffect(1.2)
                        .tint(.orange)
                    
                    Text(String(format: "%.0f%%", deletionProgress * 100))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                }
            }
            
            VStack(spacing: 8) {
                Text("Deleting Files...")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(deletionMessage)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(40)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .frame(maxWidth: 400)
        .padding(40)
    }
    
    // MARK: - Modern Toast View
    struct ModernToastView: View {
        let message: String
        let type: ToastType
        
        var body: some View {
            VStack {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(type.color.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: type.icon)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundStyle(type.color)
                    }
                    
                    Text(message)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Bottom Actions View (Old)
    private var bottomActionsView: some View {
        HStack(spacing: 12) {
            Button("Deselect All") {
                selectedItems.removeAll()
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(selectedCount) file(s) selected")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(selectedSize.formatBytes())
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            Button {
                showingDeletionConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete Selected")
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
    
    // MARK: - Deletion Progress View
    private var deletionProgressView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Deleting Files...")
                    .font(.headline)
                
                HStack {
                    SwiftUI.ProgressView()
                        .scaleEffect(0.8)
                        .frame(width: 16, height: 16)
                    Text(String(format: "%.0f%%", deletionProgress * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(deletionMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 4)
        }
        .padding()
        .frame(maxWidth: 400)
    }
    
    // MARK: - Modern Deletion Confirmation Sheet
    private var modernDeletionConfirmationSheet: some View {
        VStack(spacing: 32) {
            // Header with Icon
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.orange.opacity(0.2), .red.opacity(0.1)],
                                center: .center,
                                startRadius: 30,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 48, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Confirm Deletion")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Are you sure you want to delete these files?")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Modern Stats Cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                VStack(spacing: 8) {
                    Text("\(selectedCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Files to delete")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                
                VStack(spacing: 8) {
                    Text(selectedSize.formatBytes())
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Total size")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
            }
            
            // Info Card
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
                
                Text("Files will be moved to Trash and can be recovered.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.blue.opacity(0.3), lineWidth: 1)
            )
            
            // Action Buttons
            HStack(spacing: 16) {
                modernActionButton(
                    title: "Cancel",
                    icon: "xmark",
                    gradient: [.gray, .secondary],
                    action: { showingDeletionConfirmation = false },
                    id: "cancel_deletion"
                )
                
                modernActionButton(
                    title: "Delete Files",
                    icon: "trash.fill",
                    gradient: [.red, .pink],
                    action: {
                        showingDeletionConfirmation = false
                        performDeletion()
                    },
                    id: "confirm_deletion"
                )
            }
        }
        .padding(32)
        .frame(minWidth: 500, maxWidth: 600)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 30, x: 0, y: 15)
    }
    
    // MARK: - Modern Export Sheet
    private var modernExportSheet: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                                center: .center,
                                startRadius: 30,
                                endRadius: 60
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 40, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Export Results")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Choose export format")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Export Options
            VStack(spacing: 16) {
                Button {
                    exportResults(as: CleanME.ExportFormat.csv)
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.green.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "doc.text")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.green)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export as CSV")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Text("Comma-separated values for Excel")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                Button {
                    exportResults(as: CleanME.ExportFormat.json)
                } label: {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.orange.opacity(0.2))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "doc.badge.gearshape")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(.orange)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Export as JSON")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Text("Structured data with full details")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(20)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            // Cancel Button
            modernActionButton(
                title: "Cancel",
                icon: "xmark",
                gradient: [.gray, .secondary],
                action: { showingExportSheet = false },
                id: "cancel_export"
            )
        }
        .padding(32)
        .frame(minWidth: 450, maxWidth: 500)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.1), radius: 30, x: 0, y: 15)
    }
    
    // MARK: - Deletion Confirmation Sheet (Old)
    private var deletionConfirmationSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.orange)
                
                Text("Confirm Deletion")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Are you sure you want to delete these files?")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Stats
            VStack(spacing: 8) {
                HStack {
                    Text("Files to delete:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(selectedCount)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Total size:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(selectedSize.formatBytes())
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                }
                
                HStack {
                    Text("Deletion method:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Move to Trash")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            
            // Warning
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Files will be moved to Trash and can be recovered.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Actions
            HStack(spacing: 12) {
                Button("Cancel") {
                    showingDeletionConfirmation = false
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut(.cancelAction)
                
                Button {
                    showingDeletionConfirmation = false
                    performDeletion()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(minWidth: 450)
    }
    
    // MARK: - Export Sheet
    private var exportSheet: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                
                Text("Export Results")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    exportResults(as: CleanME.ExportFormat.csv)
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Export as CSV")
                                .font(.headline)
                            Text("Comma-separated values for Excel")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button {
                    exportResults(as: CleanME.ExportFormat.json)
                } label: {
                    HStack {
                        Image(systemName: "doc.badge.gearshape")
                            .frame(width: 24)
                        VStack(alignment: .leading) {
                            Text("Export as JSON")
                                .font(.headline)
                            Text("Structured data with full details")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            
            Button("Cancel") {
                showingExportSheet = false
            }
            .buttonStyle(.bordered)
        }
        .padding(24)
        .frame(minWidth: 400)
    }
    
    // MARK: - Helper Functions
    private func toggleSelection(for id: UUID) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }
    
    private func toggleSelectAll() {
        if selectedCount == filteredResults.count {
            selectedItems.removeAll()
        } else {
            selectedItems = Set(filteredResults.map { $0.id })
        }
    }
    
    private func performDeletion() {
        isDeleting = true
        deletionProgress = 0.0
        deletionMessage = "Preparing to delete files..."
        
        Task {
            let itemsToDelete = scanEngine.scanResults.filter { selectedItems.contains($0.id) }
            
            let result = await scanEngine.deleteItems(itemsToDelete) { progress, message in
                await MainActor.run {
                    deletionProgress = progress
                    deletionMessage = message
                }
            }
            
            await MainActor.run {
                isDeleting = false
                selectedItems.removeAll()
                
                let isSuccess = result.failedCount == 0
                let freedSpace = result.totalSizeDeleted
                
                if isSuccess {
                    toastMessage = "Successfully deleted \(result.deletedCount) file(s) (\(freedSpace.formatBytes()))"
                    toastType = .success
                } else {
                    toastMessage = "Deleted \(result.deletedCount)/\(itemsToDelete.count) files. \(result.failedCount) error(s)"
                    toastType = .warning
                }
                
                showToast()
            }
        }
    }
    
    private func exportResults(as format: CleanME.ExportFormat) {
        showingExportSheet = false
        
        let panel = NSSavePanel()
        panel.allowedContentTypes = format == .csv ? [.commaSeparatedText] : [.json]
        panel.nameFieldStringValue = "CleanMe_Results_\(Date().formatted(.iso8601.year().month().day()))"
        
        panel.begin { response in
            guard response == .OK, let url = panel.url else { return }
            
            Task {
                do {
                    let itemsToExport = selectedCount > 0 ? selectedItems : Set(filteredResults.map { $0.id })
                    try await scanEngine.exportResults(to: url, selectedItems: itemsToExport, format: format)
                    
                    await MainActor.run {
                        toastMessage = "Results exported successfully"
                        toastType = .success
                        showToast()
                    }
                } catch {
                    await MainActor.run {
                        toastMessage = "Failed to export: \(error.localizedDescription)"
                        toastType = .error
                        showToast()
                    }
                }
            }
        }
    }
    
    private func showToast() {
        withAnimation {
            showingToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingToast = false
            }
        }
    }
    
    
    private func saveResults(name: String, location: String) {
        toastMessage = "Results saved to \(location)"
        toastType = .success
        showToast()
    }
    
    private func clearResults() {
        scanEngine.scanResults.removeAll()
        selectedItems.removeAll()
    }
    
    private func saveDraft() {
        toastMessage = "Draft saved successfully"
        toastType = .success
        showToast()
    }
    
    private func discardDraft() {
        clearResults()
        toastMessage = "Draft discarded"
        toastType = .warning
        showToast()
    }
}

// MARK: - Supporting Types
enum SortOrder: CaseIterable {
    case name, size, date, type
    
    var displayName: String {
        switch self {
        case .name: return "Name"
        case .size: return "Size"
        case .date: return "Date Modified"
        case .type: return "Type"
        }
    }
}

enum ToastType {
    case success, warning, error
    
    var color: Color {
        switch self {
        case .success: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: String
    let type: ToastType
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.title3)
                    .foregroundColor(type.color)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 8)
            .padding()
            
            Spacer()
        }
    }
}

// MARK: - Preview
struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
            .environmentObject(ScanEngine())
            .environmentObject(AppSettings())
    }
}
