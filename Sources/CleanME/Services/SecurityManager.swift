import Foundation

class SecurityManager {
    
    // Check if the application has permission to access a specific file
    func hasAccess(to fileURL: URL) -> Bool {
        let securityScopedBookmark = try? fileURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        return securityScopedBookmark != nil
    }
    
    // Request permission to access a specific file
    func requestAccess(to fileURL: URL, completion: @escaping (Bool) -> Void) {
        let securityScopedBookmark = try? fileURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        
        guard let bookmark = securityScopedBookmark else {
            completion(false)
            return
        }
        
        var isStale = false
        let resolvedURL = try? URL(resolvingBookmarkData: bookmark, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isStale)
        
        if isStale {
            // Handle stale bookmark
            completion(false)
            return
        }
        
        // Start accessing the security-scoped resource
        guard let url = resolvedURL else {
            completion(false)
            return
        }
        let success = url.startAccessingSecurityScopedResource()
        completion(success)
    }
    
    // Stop accessing a previously accessed security-scoped resource
    func stopAccessing(fileURL: URL) {
        let securityScopedBookmark = try? fileURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        
        guard let bookmark = securityScopedBookmark else { return }
        
        var isStale = false
        let resolvedURL = try? URL(resolvingBookmarkData: bookmark, options: .withoutUI, relativeTo: nil, bookmarkDataIsStale: &isStale)
        resolvedURL?.stopAccessingSecurityScopedResource()
    }
    
    // MARK: - Advanced Security Methods
    
    func checkFilePermissions(for filePath: String) -> FilePermissionInfo {
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: filePath)
        
        var isAccessible = false
        var canDelete = false
        var requiredPermission: SecurityPermissionLevel = .user
        
        // Check if file exists
        guard fileManager.fileExists(atPath: filePath) else {
            return FilePermissionInfo(
                path: filePath,
                requiredPermission: .user,
                isAccessible: false,
                canDelete: false
            )
        }
        
        // Check basic accessibility
        isAccessible = fileManager.isReadableFile(atPath: filePath)
        
        // Check if file is writable (indicates deletion possibility)
        let parentDirectory = fileURL.deletingLastPathComponent().path
        canDelete = fileManager.isWritableFile(atPath: parentDirectory)
        
        // Determine required permission level
        if isSystemFile(path: filePath) {
            requiredPermission = .system
            canDelete = false
        } else if isProtectedFile(path: filePath) {
            requiredPermission = .admin
        } else {
            requiredPermission = .user
        }
        
        return FilePermissionInfo(
            path: filePath,
            requiredPermission: requiredPermission,
            isAccessible: isAccessible,
            canDelete: canDelete
        )
    }
    
    func isSystemFile(path: String) -> Bool {
        let systemPaths = [
            "/System/",
            "/usr/bin/",
            "/usr/sbin/",
            "/bin/",
            "/sbin/",
            "/Library/Apple/",
            "/Library/Audio/",
            "/Library/Frameworks/",
            "/Library/LaunchAgents/",
            "/Library/LaunchDaemons/",
            "/Library/PrivateFrameworks/",
            "/Library/SystemExtensions/"
        ]
        
        return systemPaths.contains { path.hasPrefix($0) }
    }
    
    func isProtectedFile(path: String) -> Bool {
        let protectedPaths = [
            "/Library/",
            "/var/log/",
            "/usr/local/",
            "/Applications/"
        ]
        
        // Exclude user's home directory from protected paths
        let homePath = NSHomeDirectory()
        if path.hasPrefix(homePath) {
            return false
        }
        
        return protectedPaths.contains { path.hasPrefix($0) }
    }
    
    func requestFileAccessPermission(for fileURL: URL) async -> Bool {
        return await withCheckedContinuation { continuation in
            requestAccess(to: fileURL) { success in
                continuation.resume(returning: success)
            }
        }
    }
    
    func validateSafeDeletion(items: [CleanupItem]) -> (safe: [CleanupItem], risky: [CleanupItem], forbidden: [CleanupItem]) {
        var safeItems: [CleanupItem] = []
        var riskyItems: [CleanupItem] = []
        var forbiddenItems: [CleanupItem] = []
        
        for item in items {
            let permissions = checkFilePermissions(for: item.filePath)
            
            if permissions.requiredPermission == .system || isSystemFile(path: item.filePath) {
                forbiddenItems.append(item)
            } else if permissions.requiredPermission == .admin || item.isProtected {
                riskyItems.append(item)
            } else {
                safeItems.append(item)
            }
        }
        
        return (safe: safeItems, risky: riskyItems, forbidden: forbiddenItems)
    }
    
    func createSecurityReport(for items: [CleanupItem]) -> SecurityReport {
        let validation = validateSafeDeletion(items: items)
        let totalSize = items.reduce(0) { $0 + $1.fileSize }
        let safeSize = validation.safe.reduce(0) { $0 + $1.fileSize }
        
        return SecurityReport(
            totalItems: items.count,
            safeItems: validation.safe.count,
            riskyItems: validation.risky.count,
            forbiddenItems: validation.forbidden.count,
            totalSize: totalSize,
            safeSize: safeSize,
            riskLevel: calculateRiskLevel(safe: validation.safe.count, risky: validation.risky.count, forbidden: validation.forbidden.count)
        )
    }
    
    private func calculateRiskLevel(safe: Int, risky: Int, forbidden: Int) -> SecurityRiskLevel {
        let total = safe + risky + forbidden
        guard total > 0 else { return .none }
        
        let riskyPercentage = Double(risky + forbidden) / Double(total)
        
        switch riskyPercentage {
        case 0:
            return .none
        case 0.001...0.1:
            return .low
        case 0.1...0.3:
            return .medium
        case 0.3...0.7:
            return .high
        default:
            return .critical
        }
    }
}

// MARK: - Security Report Types

struct SecurityReport {
    let totalItems: Int
    let safeItems: Int
    let riskyItems: Int
    let forbiddenItems: Int
    let totalSize: Int64
    let safeSize: Int64
    let riskLevel: SecurityRiskLevel
    
    var riskySize: Int64 {
        return totalSize - safeSize
    }
    
    var safetyPercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(safeItems) / Double(totalItems) * 100
    }
}

enum SecurityRiskLevel: String, CaseIterable {
    case none = "none"
    case low = "low"
    case medium = "medium"
    case high = "high"
    case critical = "critical"
    
    var displayName: String {
        switch self {
        case .none:
            return "No Risk"
        case .low:
            return "Low Risk"
        case .medium:
            return "Medium Risk"
        case .high:
            return "High Risk"
        case .critical:
            return "Critical Risk"
        }
    }
    
    var color: String {
        switch self {
        case .none:
            return "green"
        case .low:
            return "blue"
        case .medium:
            return "yellow"
        case .high:
            return "orange"
        case .critical:
            return "red"
        }
    }
}