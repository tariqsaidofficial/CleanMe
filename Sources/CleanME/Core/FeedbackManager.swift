import AppKit
import SwiftUI

final class FeedbackManager {
    static let shared = FeedbackManager()
    var isEnabled: Bool = true
    
    private init() {}
    
    // MARK: - Haptic Feedback
    func trigger(_ type: NSHapticFeedbackManager.FeedbackPattern = .generic) {
        guard isEnabled else { return }
        NSHapticFeedbackManager.defaultPerformer.perform(type, performanceTime: .now)
    }
    
    func success() {
        trigger(.levelChange)
    }
    
    func warning() {
        trigger(.generic)
    }
    
    func error() {
        trigger(.generic)
    }
    
    func selection() {
        trigger(.alignment)
    }
    
    func delete() {
        trigger(.alignment)
    }
    
    // MARK: - Visual Feedback
    static func impact(_ type: NSHapticFeedbackManager.FeedbackPattern) {
        NSHapticFeedbackManager.defaultPerformer.perform(type, performanceTime: .now)
    }
    
    static func flashSuccess() {
        guard let window = NSApp.keyWindow else { return }
        
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            window.contentView?.animator().alphaValue = 0.8
        } completionHandler: {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.2
                window.contentView?.animator().alphaValue = 1.0
            }
        }
    }
    
    static func flashWarning() {
        guard let window = NSApp.keyWindow else { return }
        
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            window.contentView?.animator().alphaValue = 0.9
        } completionHandler: {
            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.15
                window.contentView?.animator().alphaValue = 1.0
            }
        }
    }
    
    static func combinedFeedback(haptic: NSHapticFeedbackManager.FeedbackPattern, flash: Bool = true) {
        impact(haptic)
        if flash {
            flashSuccess()
        }
    }
}
