import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func sendNotification(title: String, body: String) {
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
