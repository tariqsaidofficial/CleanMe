import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    // Check if we're running in a test environment
    private var isTestEnvironment: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil ||
               NSClassFromString("XCTest") != nil
    }
    
    private init() {
        // Only request authorization if not in test environment
        if !isTestEnvironment {
            requestAuthorization()
        }
    }
    
    func requestAuthorization() {
        // Skip in test environment
        guard !isTestEnvironment else {
            print("⚠️ Skipping notification authorization in test environment")
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
        // Skip in test environment
        guard !isTestEnvironment else {
            print("📱 [Test] Notification: \(title) - \(body)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
    
    func sendScanCompleteNotification(filesFound: Int, totalSize: String) {
        sendNotification(
            title: "Scan Complete",
            body: "Found \(filesFound) files (\(totalSize)) ready to clean"
        )
    }
    
    func sendDeletionCompleteNotification(filesDeleted: Int, spaceFreed: String) {
        sendNotification(
            title: "Cleanup Complete",
            body: "Deleted \(filesDeleted) files and freed \(spaceFreed)"
        )
    }
}
