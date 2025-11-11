import Foundation

class AppSettings: ObservableObject {
    @Published var scanCache: Bool = true
    @Published var scanLogs: Bool = true
    @Published var scanTempFiles: Bool = true
    @Published var scanTrash: Bool = false
    @Published var scanDownloads: Bool = false
    @Published var scanDuplicates: Bool = false
    
    @Published var enableSafeMode: Bool = true
    @Published var requireAdminForSystemFiles: Bool = true
    @Published var createBackupBeforeDelete: Bool = false
    @Published var maxFileAge: Int = 30 // days
    @Published var minFileSize: Int64 = 0 // bytes
    
    @Published var excludedPaths: [String] = []
    @Published var excludedExtensions: [String] = []
    
    // UI Settings  
    @Published var showFilePreview: Bool = true
    @Published var autoRefreshResults: Bool = true
    @Published var confirmBeforeDelete: Bool = true
    @Published var enableHapticFeedback: Bool = true {
        didSet {
            FeedbackManager.shared.isEnabled = enableHapticFeedback
        }
    }
    
    // Logging
    @Published var enableLogging: Bool = true
    @Published var logLevel: LogLevel = .info
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        loadSettings()
    }
    
    func loadSettings() {
        scanCache = userDefaults.bool(forKey: "scanCache")
        scanLogs = userDefaults.bool(forKey: "scanLogs") 
        scanTempFiles = userDefaults.bool(forKey: "scanTempFiles")
        scanTrash = userDefaults.bool(forKey: "scanTrash")
        enableSafeMode = userDefaults.bool(forKey: "enableSafeMode")
        confirmBeforeDelete = userDefaults.bool(forKey: "confirmBeforeDelete")
    }
    
    func saveSettings() {
        userDefaults.set(scanCache, forKey: "scanCache")
        userDefaults.set(scanLogs, forKey: "scanLogs")
        userDefaults.set(scanTempFiles, forKey: "scanTempFiles")
        userDefaults.set(scanTrash, forKey: "scanTrash")
        userDefaults.set(enableSafeMode, forKey: "enableSafeMode")
        userDefaults.set(confirmBeforeDelete, forKey: "confirmBeforeDelete")
    }
    
    var scanTypes: [FileType] {
        var types: [FileType] = []
        if scanCache { types.append(.cache) }
        if scanLogs { types.append(.log) }
        if scanTempFiles { types.append(.temporary) }
        if scanTrash { types.append(.trash) }
        return types
    }
    
    // Reset all settings to defaults
    func resetToDefaults() {
        scanCache = true
        scanLogs = true
        scanTempFiles = true
        scanTrash = false
        scanDownloads = false
        scanDuplicates = false
        enableSafeMode = true
        requireAdminForSystemFiles = true
        createBackupBeforeDelete = false
        maxFileAge = 30
        minFileSize = 0
        excludedPaths = []
        excludedExtensions = []
        showFilePreview = true
        autoRefreshResults = true
        confirmBeforeDelete = true
        enableHapticFeedback = true
        enableLogging = true
        logLevel = .info
    }
}