import Foundation

struct ScanResult {
    let files: [CleanupItem]
    let totalSize: Int
    let cleanedFilesCount: Int
    let errors: [String]
    
    var success: Bool {
        return errors.isEmpty
    }
    
    init(files: [CleanupItem], totalSize: Int, cleanedFilesCount: Int, errors: [String] = []) {
        self.files = files
        self.totalSize = totalSize
        self.cleanedFilesCount = cleanedFilesCount
        self.errors = errors
    }
}