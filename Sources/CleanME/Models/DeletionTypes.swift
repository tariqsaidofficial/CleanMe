import Foundation

// MARK: - Deletion Result Types

struct DeletionResult {
    let deletedItems: [CleanupItem]
    let failedItems: [(CleanupItem, Error)]
    let totalSizeDeleted: Int64
    
    var deletedCount: Int {
        return deletedItems.count
    }
    
    var failedCount: Int {
        return failedItems.count
    }
    
    var successRate: Double {
        let total = deletedCount + failedCount
        guard total > 0 else { return 0.0 }
        return Double(deletedCount) / Double(total)
    }
}

// MARK: - Deletion Errors

enum DeletionError: LocalizedError {
    case systemCriticalFile(String)
    case fileNotFound(String)
    case insufficientPermissions(String)
    case backupFailed(String)
    case unknownError(String, Error)
    
    var errorDescription: String? {
        switch self {
        case .systemCriticalFile(let path):
            return "Cannot delete system critical file: \(path)"
        case .fileNotFound(let path):
            return "File not found: \(path)"
        case .insufficientPermissions(let path):
            return "Insufficient permissions to delete: \(path)"
        case .backupFailed(let path):
            return "Failed to create backup for: \(path)"
        case .unknownError(let path, let error):
            return "Unknown error deleting \(path): \(error.localizedDescription)"
        }
    }
}

// MARK: - Security Permission Types

enum SecurityPermissionLevel {
    case user
    case admin
    case system
}

struct FilePermissionInfo {
    let path: String
    let requiredPermission: SecurityPermissionLevel
    let isAccessible: Bool
    let canDelete: Bool
}
