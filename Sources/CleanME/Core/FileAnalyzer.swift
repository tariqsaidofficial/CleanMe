import Foundation

class FileAnalyzer {
    static let shared = FileAnalyzer()
    
    private init() {}
    
    func analyzeFilesBySize(_ items: [CleanupItem]) -> [String: Int64] {
        var sizeByType: [String: Int64] = [:]
        
        for item in items {
            let typeName = item.fileType.displayName
            sizeByType[typeName, default: 0] += item.fileSize
        }
        
        return sizeByType
    }
    
    func analyzeFilesByType(_ items: [CleanupItem]) -> [String: Int] {
        var countByType: [String: Int] = [:]
        
        for item in items {
            let typeName = item.fileType.displayName
            countByType[typeName, default: 0] += 1
        }
        
        return countByType
    }
    
    func findLargestFiles(_ items: [CleanupItem], limit: Int = 10) -> [CleanupItem] {
        return items.sorted { $0.fileSize > $1.fileSize }.prefix(limit).map { $0 }
    }
    
    func findOldestFiles(_ items: [CleanupItem], limit: Int = 10) -> [CleanupItem] {
        return items.sorted { $0.lastModified < $1.lastModified }.prefix(limit).map { $0 }
    }
    
    func calculateTotalSize(_ items: [CleanupItem]) -> Int64 {
        return items.reduce(0) { $0 + $1.fileSize }
    }
    
    func filterByMinimumSize(_ items: [CleanupItem], minimumSize: Int64) -> [CleanupItem] {
        return items.filter { $0.fileSize >= minimumSize }
    }
    
    func filterByAge(_ items: [CleanupItem], olderThanDays days: Int) -> [CleanupItem] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return items.filter { $0.lastModified < cutoffDate }
    }
}
