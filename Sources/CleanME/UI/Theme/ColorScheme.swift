import SwiftUI

// MARK: - Unified Color Scheme
struct AppColors {
    // MARK: - Primary Colors (Blue Gradient)
    static let primaryBlue = Color.blue
    static let primaryLightBlue = Color(red: 0.4, green: 0.6, blue: 1.0)
    static let primaryGradient = [primaryBlue, primaryLightBlue]
    
    // MARK: - Accent Colors (Maroon Gradient)
    static let accentMaroon = Color(red: 0.8, green: 0.2, blue: 0.3)
    static let accentDarkMaroon = Color(red: 0.6, green: 0.1, blue: 0.2)
    static let accentGradient = [accentMaroon, accentDarkMaroon]
    
    // MARK: - Status Colors (Keep semantic colors)
    static let successGreen = Color.green
    static let successMint = Color.mint
    static let successGradient = [successGreen, successMint]
    
    static let warningOrange = Color.orange
    static let warningYellow = Color.yellow
    static let warningGradient = [warningOrange, warningYellow]
    
    static let errorRed = Color.red
    static let errorPink = Color.pink
    static let errorGradient = [errorRed, errorPink]
    
    // MARK: - System Colors
    static let systemGray = Color.gray
    static let systemSecondary = Color.secondary
    static let systemClear = Color.clear
    
    // MARK: - Background Gradients
    static func backgroundGradient(isActive: Bool = false) -> some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    primaryBlue.opacity(0.1),
                    primaryLightBlue.opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated mesh overlay
            RadialGradient(
                colors: [
                    isActive ? accentMaroon.opacity(0.15) : primaryBlue.opacity(0.15),
                    isActive ? accentDarkMaroon.opacity(0.08) : primaryLightBlue.opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Helper Functions
    static func gradientForType(_ type: ColorType) -> [Color] {
        switch type {
        case .primary:
            return primaryGradient
        case .accent:
            return accentGradient
        case .success:
            return successGradient
        case .warning:
            return warningGradient
        case .error:
            return errorGradient
        }
    }
}

// MARK: - Color Type Enum
enum ColorType {
    case primary    // Blue gradient
    case accent     // Maroon gradient
    case success    // Green gradient
    case warning    // Orange gradient
    case error      // Red gradient
}

// MARK: - View Extensions
extension View {
    func modernBackground(isActive: Bool = false) -> some View {
        self.background(AppColors.backgroundGradient(isActive: isActive))
    }
}
