import Foundation
import SwiftUI

struct FileItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let dateModified: Date
    let size: Int64
    let type: String
    
    var sizeFormatted: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var icon: String {
        switch type.lowercased() {
        case "cache": return "folder.fill"
        case "log": return "doc.text.fill"
        case "temporary": return "clock.fill"
        case "trash": return "trash.fill"
        case "download": return "arrow.down.circle.fill"
        default: return "doc.fill"
        }
    }
    
    var iconColor: Color {
        switch type.lowercased() {
        case "cache": return .blue
        case "log": return .green
        case "temporary": return .orange
        case "trash": return .red
        case "download": return .purple
        default: return .gray
        }
    }
}
