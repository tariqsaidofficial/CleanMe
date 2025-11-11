import Foundation

class ScanEngine: ObservableObject {
    @Published var scanResults: [CleanupItem] = []
    @Published var isScanning = false
    @Published var totalSize: Int64 = 0
    @Published var fileItems: [FileItem] = []
    
    private var scanTask: Task<Void, Never>?
    
    func performFullScan(progressCallback: @escaping (Double, String) async -> Void) async {
        isScanning = true
        scanResults.removeAll()
        totalSize = 0
        
        var allItems: [CleanupItem] = []
        
        // Scan cache directories
        await progressCallback(0.08, "Scanning cache files...")
        let cacheItems = await scanCacheDirectories()
        allItems.append(contentsOf: cacheItems)
        
        // Scan log directories  
        await progressCallback(0.2, "Scanning log files...")
        let logItems = await scanLogDirectories()
        allItems.append(contentsOf: logItems)
        
        // Scan temporary directories
        await progressCallback(0.32, "Scanning temporary files...")
        let tempItems = await scanTemporaryDirectories()
        allItems.append(contentsOf: tempItems)
        
        // Scan trash/recycle bin
        await progressCallback(0.44, "Scanning trash bin...")
        let trashItems = await scanTrashDirectories()
        allItems.append(contentsOf: trashItems)
        
        // Scan downloads folder
        await progressCallback(0.56, "Analyzing downloads folder...")
        let downloadItems = await scanDownloadsDirectory()
        allItems.append(contentsOf: downloadItems)
        
        // Find duplicate files (faster scan)
        await progressCallback(0.68, "Finding duplicate files...")
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        let duplicateItems = await findDuplicateFiles()
        allItems.append(contentsOf: duplicateItems)
        
        // Scan for large files
        await progressCallback(0.80, "Identifying large files...")
        let largeFiles = await scanForLargeFiles()
        allItems.append(contentsOf: largeFiles)
        
        // Scan for empty folders
        await progressCallback(0.92, "Finding empty folders...")
        let emptyFolders = await scanForEmptyFolders()
        allItems.append(contentsOf: emptyFolders)
        
        // Update results
        let finalResults = allItems
        let finalSize = finalResults.reduce(0) { $0 + $1.fileSize }
        
        // Convert to FileItem
        let convertedFileItems = finalResults.map { item in
            FileItem(
                name: item.fileName,
                dateModified: item.lastModified,
                size: item.fileSize,
                type: item.fileType.displayName
            )
        }
        
        await MainActor.run {
            self.scanResults = finalResults
            self.totalSize = finalSize
            self.fileItems = convertedFileItems
            self.isScanning = false
            
            // Send notification
            let formatter = ByteCountFormatter()
            formatter.allowedUnits = [.useKB, .useMB, .useGB]
            formatter.countStyle = .file
            let sizeString = formatter.string(fromByteCount: finalSize)
            
            NotificationManager.shared.sendScanCompleteNotification(
                filesFound: finalResults.count,
                totalSize: sizeString
            )
        }
        
        await progressCallback(1.0, "Scan completed")
    }
    
    func scanCacheDirectories() async -> [CleanupItem] {
        var items: [CleanupItem] = []
        let cachePaths = [
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path ?? "",
            "/Library/Caches"
        ]
        
        for path in cachePaths {
            let pathItems = await scanDirectory(path: path, fileType: .cache)
            items.append(contentsOf: pathItems)
        }
        
        return items
    }
    
    func scanLogDirectories() async -> [CleanupItem] {
        var items: [CleanupItem] = []
        let logPaths = [
            NSHomeDirectory() + "/Library/Logs",
            "/var/log"
        ]
        
        for path in logPaths {
            let pathItems = await scanDirectory(path: path, fileType: .log)
            items.append(contentsOf: pathItems)
        }
        
        return items
    }
    
    func scanTemporaryDirectories() async -> [CleanupItem] {
        var items: [CleanupItem] = []
        let tempPaths = [
            "/tmp",
            "/var/tmp",
            NSTemporaryDirectory()
        ]
        
        for path in tempPaths {
            let pathItems = await scanDirectory(path: path, fileType: .temporary)
            items.append(contentsOf: pathItems)
        }
        
        return items
    }
    
    // MARK: - New Scan Methods
    
    func scanTrashDirectories() async -> [CleanupItem] {
        var items: [CleanupItem] = []
        let trashPaths = [
            NSHomeDirectory() + "/.Trash",
            "/Users/Shared/.Trash"
        ]
        
        for path in trashPaths {
            let pathItems = await scanDirectory(path: path, fileType: .trash)
            items.append(contentsOf: pathItems)
        }
        
        return items
    }
    
    func scanDownloadsDirectory() async -> [CleanupItem] {
        var items: [CleanupItem] = []
        
        guard let downloadsURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first else {
            return items
        }
        
        let downloadsPath = downloadsURL.path
        let pathItems = await scanDirectory(path: downloadsPath, fileType: .download)
        
        // Filter for files older than 30 days or larger than 100MB
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let largeSizeThreshold: Int64 = 100 * 1024 * 1024 // 100MB
        
        let filteredItems = pathItems.filter { item in
            return item.lastModified < thirtyDaysAgo || item.fileSize > largeSizeThreshold
        }
        
        items.append(contentsOf: filteredItems)
        return items
    }
    
    func findDuplicateFiles() async -> [CleanupItem] {
        var items: [CleanupItem] = []
        var fileHashes: [String: [CleanupItem]] = [:]
        
        // Common directories to check for duplicates
        let searchPaths = [
            NSHomeDirectory() + "/Documents",
            NSHomeDirectory() + "/Downloads",
            NSHomeDirectory() + "/Desktop"
        ]
        
        for path in searchPaths {
            let pathItems = await scanDirectoryForDuplicates(path: path)
            
            for item in pathItems {
                let fileHash = await calculateFileHash(filePath: item.filePath)
                if !fileHash.isEmpty {
                    fileHashes[fileHash, default: []].append(item)
                }
            }
        }
        
        // Find actual duplicates (hash appears more than once)
        for (_, duplicateGroup) in fileHashes where duplicateGroup.count > 1 {
            // Keep the first file, mark others as duplicates
            let duplicatesToRemove = Array(duplicateGroup.dropFirst())
            for duplicate in duplicatesToRemove {
                let duplicateItem = CleanupItem(
                    fileName: duplicate.fileName,
                    filePath: duplicate.filePath,
                    fileSize: duplicate.fileSize,
                    fileType: .duplicate,
                    lastModified: duplicate.lastModified,
                    isProtected: duplicate.isProtected
                )
                items.append(duplicateItem)
            }
        }
        
        return items
    }
    
    func scanDirectoryForDuplicates(path: String) async -> [CleanupItem] {
        return await Task.detached { [weak self] in
            guard let self = self else { return [] }
            
            var items: [CleanupItem] = []
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: path),
                  let enumerator = fileManager.enumerator(atPath: path) else {
                return items
            }
            
            // Convert to array to avoid async iteration issues in Swift 6
            let allFiles = enumerator.allObjects.compactMap { $0 as? String }
            
            for fileName in allFiles {
                let fullPath = (path as NSString).appendingPathComponent(fileName)
                
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    let modificationDate = attributes[.modificationDate] as? Date ?? Date()
                    
                    // Only check files larger than 1MB for duplicates
                    guard fileSize > 1024 * 1024,
                          !self.isSystemCriticalFile(path: fullPath) else {
                        continue
                    }
                    
                    let item = CleanupItem(
                        fileName: fileName,
                        filePath: fullPath,
                        fileSize: fileSize,
                        fileType: .duplicate, // Will be used temporarily
                        lastModified: modificationDate,
                        isProtected: self.isProtectedFile(path: fullPath)
                    )
                    
                    items.append(item)
                } catch {
                    continue
                }
            }
            
            return items
        }.value
    }
    
    private func calculateFileHash(filePath: String) async -> String {
        return await Task.detached {
            guard let data = FileManager.default.contents(atPath: filePath) else {
                return ""
            }
            
            // For large files, only hash first and last 1KB + file size
            if data.count > 1024 * 1024 { // 1MB
                let firstPart = data.prefix(1024)
                let lastPart = data.suffix(1024)
                let combinedData = firstPart + lastPart + Data("\(data.count)".utf8)
                return combinedData.base64EncodedString()
            } else {
                return data.base64EncodedString()
            }
        }.value
    }
    
    func scanDirectory(path: String, fileType: FileType) async -> [CleanupItem] {
        return await Task.detached { [weak self] in
            guard let self = self else { return [] }
            
            var items: [CleanupItem] = []
            let fileManager = FileManager.default
            
            guard fileManager.fileExists(atPath: path),
                  let enumerator = fileManager.enumerator(atPath: path) else {
                return items
            }
            
            // Convert to array to avoid async iteration issues in Swift 6
            let allFiles = enumerator.allObjects.compactMap { $0 as? String }
            
            for fileName in allFiles {
                let fullPath = (path as NSString).appendingPathComponent(fileName)
                
                do {
                    let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    let modificationDate = attributes[.modificationDate] as? Date ?? Date()
                    
                    // Skip very small files and system critical files
                    guard fileSize > 1024, // Skip files smaller than 1KB
                          !self.isSystemCriticalFile(path: fullPath) else {
                        continue
                    }
                    
                    let item = CleanupItem(
                        fileName: fileName,
                        filePath: fullPath,
                        fileSize: fileSize,
                        fileType: fileType,
                        lastModified: modificationDate,
                        isProtected: self.isProtectedFile(path: fullPath)
                    )
                    
                    items.append(item)
                } catch {
                    // Skip files we can't access
                    continue
                }
            }
            
            return items
        }.value
    }
    
    private func isSystemCriticalFile(path: String) -> Bool {
        let criticalPaths = [
            "/System/",
            "/usr/",
            "/bin/",
            "/sbin/"
        ]
        
        return criticalPaths.contains { path.hasPrefix($0) }
    }
    
    private func isProtectedFile(path: String) -> Bool {
        let protectedPaths = [
            "/Library/",
            "/var/log/system.log"
        ]
        
        return protectedPaths.contains { path.hasPrefix($0) }
    }
    
    // MARK: - Safe File Deletion
    
    func deleteItems(_ items: [CleanupItem], progressCallback: @escaping (Double, String) async -> Void) async -> DeletionResult {
        var deletedItems: [CleanupItem] = []
        var failedItems: [(CleanupItem, Error)] = []
        var totalSize: Int64 = 0
        
        let totalItems = items.count
        
        for (index, item) in items.enumerated() {
            let progress = Double(index) / Double(totalItems)
            await progressCallback(progress, "Deleting \(item.fileName)...")
            
            do {
                let success = try await deleteItemSafely(item)
                if success {
                    deletedItems.append(item)
                    totalSize += item.fileSize
                }
            } catch {
                failedItems.append((item, error))
            }
        }
        
        await progressCallback(1.0, "Deletion completed")
        
        return DeletionResult(
            deletedItems: deletedItems,
            failedItems: failedItems,
            totalSizeDeleted: totalSize
        )
    }
    
    private func deleteItemSafely(_ item: CleanupItem) async throws -> Bool {
        let fileManager = FileManager.default
        let filePath = item.filePath
        
        // Security checks
        guard !isSystemCriticalFile(path: filePath) else {
            throw DeletionError.systemCriticalFile(filePath)
        }
        
        guard fileManager.fileExists(atPath: filePath) else {
            throw DeletionError.fileNotFound(filePath)
        }
        
        // Check if file is protected
        if item.isProtected {
            let hasPermission = await requestAdminPermissionIfNeeded(for: filePath)
            guard hasPermission else {
                throw DeletionError.insufficientPermissions(filePath)
            }
        }
        
        // Create backup if needed (for important files)
        if shouldCreateBackup(for: item) {
            try await createBackup(for: item)
        }
        
        // Perform deletion
        return try await Task.detached {
            do {
                if item.fileType == .trash {
                    // Permanently delete trash items
                    try fileManager.removeItem(atPath: filePath)
                } else {
                    // Move to trash for other items
                    let trashURL = try fileManager.url(for: .trashDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                    let sourceURL = URL(fileURLWithPath: filePath)
                    let fileName = sourceURL.lastPathComponent
                    let destinationURL = trashURL.appendingPathComponent(fileName)
                    
                    // Handle duplicate names in trash
                    var finalDestinationURL = destinationURL
                    var counter = 1
                    while fileManager.fileExists(atPath: finalDestinationURL.path) {
                        let nameWithoutExtension = (fileName as NSString).deletingPathExtension
                        let pathExtension = (fileName as NSString).pathExtension
                        let newName = pathExtension.isEmpty ? "\(nameWithoutExtension)_\(counter)" : "\(nameWithoutExtension)_\(counter).\(pathExtension)"
                        finalDestinationURL = trashURL.appendingPathComponent(newName)
                        counter += 1
                    }
                    
                    try fileManager.moveItem(at: sourceURL, to: finalDestinationURL)
                }
                return true
            } catch {
                throw error
            }
        }.value
    }
    
    private func shouldCreateBackup(for item: CleanupItem) -> Bool {
        // Create backup for important file types or large files
        return (item.fileType == .download && item.fileSize > 50 * 1024 * 1024) || // Files > 50MB
               item.filePath.contains("/Documents/") ||
               item.filePath.contains("/Desktop/")
    }
    
    private func createBackup(for item: CleanupItem) async throws {
        let fileManager = FileManager.default
        let backupDir = createBackupDirectory()
        
        let sourceURL = URL(fileURLWithPath: item.filePath)
        let backupFileName = "\(Date().timeIntervalSince1970)_\(sourceURL.lastPathComponent)"
        let backupURL = backupDir.appendingPathComponent(backupFileName)
        
        try await Task.detached {
            try fileManager.copyItem(at: sourceURL, to: backupURL)
        }.value
    }
    
    private func createBackupDirectory() -> URL {
        let fileManager = FileManager.default
        let homeURL = fileManager.homeDirectoryForCurrentUser
        let backupURL = homeURL.appendingPathComponent(".CleanME_Backups")
        
        if !fileManager.fileExists(atPath: backupURL.path) {
            try? fileManager.createDirectory(at: backupURL, withIntermediateDirectories: true)
        }
        
        return backupURL
    }
    
    private func requestAdminPermissionIfNeeded(for filePath: String) async -> Bool {
        // For protected files, we might need admin permissions
        // This is a placeholder - in a real implementation, you would
        // use Authorization Services or prompt for admin credentials
        return true
    }
    
    // MARK: - Export Functionality
    
    func exportResults(to url: URL, selectedItems: Set<UUID>, format: ExportFormat) async throws {
        let itemsToExport = scanResults.filter { selectedItems.contains($0.id) }
        
        switch format {
        case .csv:
            try await exportToCSV(items: itemsToExport, url: url)
        case .json:
            try await exportToJSON(items: itemsToExport, url: url)
        }
    }
    
    private func exportToCSV(items: [CleanupItem], url: URL) async throws {
        var csvContent = "File Name,File Path,File Size (Bytes),File Size (MB),File Type,Last Modified,Is Protected\n"
        
        for item in items {
            let sizeInMB = String(format: "%.2f", Double(item.fileSize) / (1024.0 * 1024.0))
            let modifiedDate = DateFormatter.exportFormatter.string(from: item.lastModified)
            
            csvContent += "\"\(item.fileName)\",\"\(item.filePath)\",\(item.fileSize),\(sizeInMB),\(item.fileType.displayName),\(modifiedDate),\(item.isProtected)\n"
        }
        
        try await Task.detached {
            try csvContent.write(to: url, atomically: true, encoding: .utf8)
        }.value
    }
    
    private func exportToJSON(items: [CleanupItem], url: URL) async throws {
        let exportData = ExportData(
            exportDate: Date(),
            totalItems: items.count,
            totalSize: items.reduce(0) { $0 + $1.fileSize },
            items: items.map { ExportItem(from: $0) }
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let jsonData = try encoder.encode(exportData)
        
        try await Task.detached {
            try jsonData.write(to: url)
        }.value
    }
    
    func cancelScan() {
        scanTask?.cancel()
        scanTask = nil
        isScanning = false
    }
    
    // MARK: - Public Scan Methods
    
    func startScan() async {
        guard !isScanning else { return }
        
        scanTask = Task {
            await performFullScan { progress, message in
                await MainActor.run {
                    // Progress updates
                }
            }
        }
    }
    
    func stopScan() {
        scanTask?.cancel()
        isScanning = false
    }
}

// MARK: - Large Files and Empty Folders Scanning

extension ScanEngine {
    func scanForLargeFiles(minimumSize: Int64 = 100 * 1024 * 1024) async -> [CleanupItem] {
        return await Task.detached { [weak self] in
            guard let self = self else { return [] }
            
            var items: [CleanupItem] = []
            let fileManager = FileManager.default
            
            let searchPaths = [
                NSHomeDirectory() + "/Documents",
                NSHomeDirectory() + "/Downloads",
                NSHomeDirectory() + "/Desktop",
                NSHomeDirectory() + "/Movies",
                NSHomeDirectory() + "/Music"
            ]
            
            for path in searchPaths {
                guard fileManager.fileExists(atPath: path),
                      let enumerator = fileManager.enumerator(atPath: path) else {
                    continue
                }
                
                // Convert to array to avoid async iteration issues in Swift 6
                let allFiles = enumerator.allObjects.compactMap { $0 as? String }
                
                for fileName in allFiles {
                    let fullPath = (path as NSString).appendingPathComponent(fileName)
                    
                    do {
                        let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                        
                        // Check if it's a file (not directory)
                        guard let fileType = attributes[.type] as? FileAttributeType,
                              fileType == .typeRegular else {
                            continue
                        }
                        
                        let fileSize = attributes[.size] as? Int64 ?? 0
                        let modificationDate = attributes[.modificationDate] as? Date ?? Date()
                        
                        // Only include files larger than minimum size
                        guard fileSize >= minimumSize,
                              !self.isSystemCriticalFile(path: fullPath) else {
                            continue
                        }
                        
                        let item = CleanupItem(
                            fileName: fileName,
                            filePath: fullPath,
                            fileSize: fileSize,
                            fileType: .download, // Use download type for large files
                            lastModified: modificationDate,
                            isProtected: self.isProtectedFile(path: fullPath)
                        )
                        
                        items.append(item)
                    } catch {
                        continue
                    }
                }
            }
            
            // Sort by size (largest first)
            items.sort { $0.fileSize > $1.fileSize }
            return items
        }.value
    }
    
    func scanForEmptyFolders() async -> [CleanupItem] {
        return await Task.detached { [weak self] in
            guard let self = self else { return [] }
            
            var items: [CleanupItem] = []
            let fileManager = FileManager.default
            
            let searchPaths = [
                NSHomeDirectory() + "/Documents",
                NSHomeDirectory() + "/Downloads",
                NSHomeDirectory() + "/Desktop"
            ]
            
            for path in searchPaths {
                guard fileManager.fileExists(atPath: path),
                      let enumerator = fileManager.enumerator(atPath: path) else {
                    continue
                }
                
                // Convert to array to avoid async iteration issues in Swift 6
                let allItems = enumerator.allObjects.compactMap { $0 as? String }
                
                for dirName in allItems {
                    let fullPath = (path as NSString).appendingPathComponent(dirName)
                    
                    var isDirectory: ObjCBool = false
                    guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
                          isDirectory.boolValue else {
                        continue
                    }
                    
                    do {
                        // Check if directory is empty
                        let contents = try fileManager.contentsOfDirectory(atPath: fullPath)
                        
                        if contents.isEmpty {
                            let attributes = try fileManager.attributesOfItem(atPath: fullPath)
                            let modificationDate = attributes[.modificationDate] as? Date ?? Date()
                            
                            let item = CleanupItem(
                                fileName: dirName,
                                filePath: fullPath,
                                fileSize: 0,
                                fileType: .temporary, // Use temporary type for empty folders
                                lastModified: modificationDate,
                                isProtected: self.isProtectedFile(path: fullPath)
                            )
                            
                            items.append(item)
                        }
                    } catch {
                        continue
                    }
                }
            }
            
            return items
        }.value
    }
}