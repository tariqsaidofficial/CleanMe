import Foundation

class FileManagerService {
    
    // Function to get a list of files in a specified directory
    func listFiles(in directory: URL) -> [URL]? {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            return fileURLs
        } catch {
            print("Error while enumerating files \(directory.path): \(error)")
            return nil
        }
    }
    
    // Function to delete a specified file
    func deleteFile(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("Error deleting file at \(url.path): \(error)")
            return false
        }
    }
    
    // Function to get the size of a file
    func fileSize(at url: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = attributes[FileAttributeKey.size] as? NSNumber {
                return fileSize.int64Value
            }
        } catch {
            print("Error getting file size at \(url.path): \(error)")
        }
        return nil
    }
    
    // Function to clear cache directory
    func clearCache() -> Bool {
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return false
        }
        
        guard let files = listFiles(in: cacheDirectory) else {
            return false
        }
        
        var success = true
        for file in files {
            if !deleteFile(at: file) {
                success = false
            }
        }
        return success
    }
}