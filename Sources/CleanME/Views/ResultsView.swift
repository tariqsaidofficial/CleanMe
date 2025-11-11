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
            VStack(spacing: 0) {
                // Header with stats
                headerView
                
                // Search and controls
                controlsView
                
                // Results list
                if filteredResults.isEmpty {
                    emptyStateView
                } else {
                    resultsListView
                }
                
                // Bottom actions
                if !selectedItems.isEmpty && !isDeleting {
                    bottomActionsView
                }
                
                // Progress indicator
                if isDeleting {
                    deletionProgressView
                }
            }
            
            // Toast message overlay
            if showingToast {
                ToastView(message: toastMessage, type: toastType)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .navigationTitle("Scan Results")
        .sheet(isPresented: $showingDeletionConfirmation) {
            deletionConfirmationSheet
        }
        .sheet(isPresented: $showingExportSheet) {
            exportSheet
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(scanEngine.scanResults.count)")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .center, spacing: 4) {
                    Text("Selected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(selectedCount)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedCount > 0 ? .blue : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(selectedCount > 0 ? "Selected Size" : "Total Size")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(formatBytes(selectedCount > 0 ? selectedSize : scanEngine.totalSize))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedCount > 0 ? .orange : .blue)
                }
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
    
    // MARK: - Controls View
    private var controlsView: some View {
        HStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search in results...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(Color(.controlBackgroundColor))
            .cornerRadius(8)
            
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
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("Sort")
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            
            // Select all / Deselect all
            Button(action: toggleSelectAll) {
                Text(selectedCount == filteredResults.count ? "Deselect All" : "Select All")
            }
            .buttonStyle(.bordered)
            .fixedSize()
            
            // Export button
            Button(action: { showingExportSheet = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
            }
            .buttonStyle(.bordered)
            .fixedSize()
            .disabled(filteredResults.isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Results List View
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
    
    // MARK: - Bottom Actions View
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
                Text(formatBytes(selectedSize))
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
    
    // MARK: - Deletion Confirmation Sheet
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
                    Text(formatBytes(selectedSize))
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
                    toastMessage = "Successfully deleted \(result.deletedCount) file(s) (\(formatBytes(freedSpace)))"
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
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
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
