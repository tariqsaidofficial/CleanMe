import SwiftUI
import AppKit

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var current: Theme = .system
    @Published var adaptiveAccentColor: Color = .accentColor
    
    private init() {
        extractAccentFromWallpaper()
    }
    
    func extractAccentFromWallpaper() {
        guard let screen = NSScreen.main,
              let imageURL = NSWorkspace.shared.desktopImageURL(for: screen),
              let image = NSImage(contentsOf: imageURL) else {
            return
        }
        
        // Extract dominant color from wallpaper
        if let dominantColor = image.dominantColor() {
            DispatchQueue.main.async {
                self.adaptiveAccentColor = Color(nsColor: dominantColor)
            }
        }
    }
    
    enum Theme: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
        
        var accentColor: Color {
            switch self {
            case .system: return .accentColor
            case .light: return Color.blue
            case .dark: return Color.blue
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
}

// MARK: - NSImage Extension
extension NSImage {
    func dominantColor() -> NSColor? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var count: CGFloat = 0
        
        for y in stride(from: 0, to: height, by: 10) {
            for x in stride(from: 0, to: width, by: 10) {
                let offset = (y * width + x) * bytesPerPixel
                r += CGFloat(pixelData[offset]) / 255.0
                g += CGFloat(pixelData[offset + 1]) / 255.0
                b += CGFloat(pixelData[offset + 2]) / 255.0
                count += 1
            }
        }
        
        return NSColor(red: r / count, green: g / count, blue: b / count, alpha: 1.0)
    }
}
