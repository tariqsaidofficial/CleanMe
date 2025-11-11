import Foundation

// MARK: - Export Types

enum ExportFormat: String, CaseIterable {
    case csv = "csv"
    case json = "json"
    
    var displayName: String {
        switch self {
        case .csv:
            return "CSV (Comma Separated Values)"
        case .json:
            return "JSON (JavaScript Object Notation)"
        }
    }
    
    var fileExtension: String {
        return rawValue
    }
    
    var mimeType: String {
        switch self {
        case .csv:
            return "text/csv"
        case .json:
            return "application/json"
        }
    }
}

// MARK: - Export Data Structures

struct ExportData: Codable {
    let exportDate: Date
    let totalItems: Int
    let totalSize: Int64
    let items: [ExportItem]
    
    var appVersion: String {
        return "CleanME v1.0.0"
    }
}

struct ExportItem: Codable {
    let fileName: String
    let filePath: String
    let fileSize: Int64
    let fileSizeMB: Double
    let fileType: String
    let lastModified: Date
    let isProtected: Bool
    
    init(from cleanupItem: CleanupItem) {
        self.fileName = cleanupItem.fileName
        self.filePath = cleanupItem.filePath
        self.fileSize = cleanupItem.fileSize
        self.fileSizeMB = Double(cleanupItem.fileSize) / (1024.0 * 1024.0)
        self.fileType = cleanupItem.fileType.displayName
        self.lastModified = cleanupItem.lastModified
        self.isProtected = cleanupItem.isProtected
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let exportFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let isoFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
