import Foundation
import os.log

enum LogLevel: String, CaseIterable {
    case debug = "DEBUG"
    case info = "INFO" 
    case warning = "WARNING"
    case error = "ERROR"
    
    var osLogType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .default
        case .error:
            return .error
        }
    }
}

class Logger {
    static let shared = Logger()
    
    private let osLog = OSLog(subsystem: "com.cleanme.app", category: "general")
    private var logFileURL: URL?
    
    private init() {}
    
    func setupLogFile() {
        let logsDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?
            .appendingPathComponent("Logs")
            .appendingPathComponent("CleanME")
        
        guard let logsDir = logsDirectory else { return }
        
        do {
            try FileManager.default.createDirectory(at: logsDir, withIntermediateDirectories: true)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fileName = "cleanme-\(dateFormatter.string(from: Date())).log"
            
            logFileURL = logsDir.appendingPathComponent(fileName)
        } catch {
            os_log("Failed to create log directory: %@", log: osLog, type: .error, error.localizedDescription)
        }
    }
    
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(level.rawValue)] [\(fileName):\(line)] \(function) - \(message)"
        
        // Log to system log
        os_log("%@", log: osLog, type: level.osLogType, logMessage)
        
        // Print to console in debug builds
        #if DEBUG
        Swift.print(logMessage)
        #endif
    }
    
    static func error(_ message: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        Swift.print("[\(timestamp)] ERROR: \(message)")
    }
    
    static func info(_ message: String) {
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        Swift.print("[\(timestamp)] INFO: \(message)")
    }
}

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}