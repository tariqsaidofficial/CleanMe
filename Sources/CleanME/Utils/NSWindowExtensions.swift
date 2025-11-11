import AppKit
import SwiftUI

// MARK: - NSWindow Extensions
extension NSWindow {
    /// Makes the window always appear on top of other windows
    func setAlwaysOnTop(_ enabled: Bool) {
        if enabled {
            self.level = .floating
            self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        } else {
            self.level = .normal
            self.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary]
        }
    }
    
    /// Toggle window always on top
    func toggleAlwaysOnTop() {
        setAlwaysOnTop(level == .normal)
    }
    
    /// Center window on screen
    func centerOnScreen() {
        if let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            let windowRect = frame
            let x = screenRect.midX - windowRect.width / 2
            let y = screenRect.midY - windowRect.height / 2
            setFrame(NSRect(x: x, y: y, width: windowRect.width, height: windowRect.height), display: true)
        }
    }
    
    /// Make window transparent title bar
    func makeTransparentTitleBar() {
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        standardWindowButton(.closeButton)?.isHidden = false
        standardWindowButton(.miniaturizeButton)?.isHidden = false
        standardWindowButton(.zoomButton)?.isHidden = false
    }
}

// MARK: - SwiftUI Window Access
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow?) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.callback(view.window)
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            self.callback(nsView.window)
        }
    }
}

// MARK: - View Extension for Window Access
extension View {
    func accessWindow(_ callback: @escaping (NSWindow?) -> Void) -> some View {
        self.background(WindowAccessor(callback: callback))
    }
    
    func alwaysOnTop(_ enabled: Bool = true) -> some View {
        self.accessWindow { window in
            window?.setAlwaysOnTop(enabled)
        }
    }
}
