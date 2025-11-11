import Foundation

class SystemAnalyzer {
    static let shared = SystemAnalyzer()
    
    private init() {}
    
    func getSystemDriveInfo() -> (totalSpace: Int64, availableSpace: Int64, usedPercentage: Double)? {
        guard let homeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        do {
            let values = try homeURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ])
            
            guard let totalSpace = values.volumeTotalCapacity,
                  let availableSpace = values.volumeAvailableCapacity else {
                return nil
            }
            
            let usedSpace = totalSpace - availableSpace
            let usedPercentage = Double(usedSpace) / Double(totalSpace) * 100.0
            
            return (Int64(totalSpace), Int64(availableSpace), usedPercentage)
        } catch {
            print("Error getting system drive info: \(error)")
            return nil
        }
    }
    
    func getSmartRecommendation() -> String {
        guard let info = getSystemDriveInfo() else {
            return "Unable to analyze system drive"
        }
        
        let usedPercentage = info.usedPercentage
        
        switch usedPercentage {
        case 0..<50:
            return "Your system drive has plenty of space. Regular cleanup recommended."
        case 50..<75:
            return "Your system drive is \(Int(usedPercentage))% full. Consider a cleanup soon."
        case 75..<85:
            return "Your system drive is \(Int(usedPercentage))% full. A cleanup is recommended."
        case 85..<95:
            return "⚠️ Your system drive is \(Int(usedPercentage))% full. A deep cleanup is strongly recommended."
        default:
            return "🚨 Critical: Your system drive is \(Int(usedPercentage))% full. Immediate cleanup required!"
        }
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}
