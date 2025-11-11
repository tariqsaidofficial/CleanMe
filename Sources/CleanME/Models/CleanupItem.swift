import Foundation
import SwiftUI

/// Represents a file or directory that can be cleaned up
struct CleanupItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let fileName: String
    let filePath: String
    let fileSize: Int64
    let fileType: FileType
    let lastModified: Date
    let isProtected: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, fileName, filePath, fileSize, fileType, lastModified, isProtected
    }
    
    init(fileName: String, filePath: String, fileSize: Int64, fileType: FileType, lastModified: Date, isProtected: Bool = false) {
        self.fileName = fileName
        self.filePath = filePath
        self.fileSize = fileSize
        self.fileType = fileType
        self.lastModified = lastModified
        self.isProtected = isProtected
    }
    
    var systemIcon: String {
        switch fileType {
        case .cache:
            return "folder.fill"
        case .log:
            return "doc.text.fill"
        case .temporary:
            return "clock.fill"
        case .trash:
            return "trash.fill"
        case .download:
            return "arrow.down.circle.fill"
        case .duplicate:
            return "doc.on.doc.fill"
        }
    }
    
    var iconColor: Color {
        switch fileType {
        case .cache:
            return .blue
        case .log:
            return .green
        case .temporary:
            return .orange
        case .trash:
            return .red
        case .download:
            return .purple
        case .duplicate:
            return .yellow
        }
    }
}

enum FileType: String, CaseIterable, Codable, Comparable {
    case cache = "cache"
    case log = "log"
    case temporary = "temp"
    case trash = "trash"
    case download = "download"
    case duplicate = "duplicate"
    
    var displayName: String {
        switch self {
        case .cache:
            return "Cache Files"
        case .log:
            return "Log Files"
        case .temporary:
            return "Temporary Files"
        case .trash:
            return "Trash"
        case .download:
            return "Downloads"
        case .duplicate:
            return "Duplicate Files"
        }
    }
    
    static func < (lhs: FileType, rhs: FileType) -> Bool {
        let order: [FileType] = [.cache, .log, .temporary, .trash, .download, .duplicate]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else {
            return false
        }
        return lhsIndex < rhsIndex
    }
}