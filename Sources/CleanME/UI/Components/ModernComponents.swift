import SwiftUI

// MARK: - Modern Background Gradient
struct ModernBackgroundGradient: View {
    let isActive: Bool
    
    init(isActive: Bool = false) {
        self.isActive = isActive
    }
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    AppColors.primaryBlue.opacity(0.1),
                    AppColors.primaryLightBlue.opacity(0.05),
                    AppColors.systemClear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated mesh overlay
            RadialGradient(
                colors: [
                    isActive ? AppColors.accentMaroon.opacity(0.15) : AppColors.primaryBlue.opacity(0.15),
                    isActive ? AppColors.accentDarkMaroon.opacity(0.08) : AppColors.primaryLightBlue.opacity(0.08),
                    AppColors.systemClear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Modern Section Header
struct ModernSectionHeader: View {
    let icon: String
    let gradient: [Color]
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            center: .center,
                            startRadius: 15,
                            endRadius: 30
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Modern Action Button
struct ModernActionButton: View {
    let title: String
    let icon: String
    let gradient: [Color]
    let action: () -> Void
    let id: String
    let isDisabled: Bool
    @State private var isHovered = false
    
    init(title: String, icon: String, gradient: [Color], action: @escaping () -> Void, id: String, isDisabled: Bool = false) {
        self.title = title
        self.icon = icon
        self.gradient = gradient
        self.action = action
        self.id = id
        self.isDisabled = isDisabled
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    if isHovered && !isDisabled {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(
                                LinearGradient(
                                    colors: gradient.map { $0.opacity(0.2) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: gradient.map { $0.opacity(0.6) },
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.regularMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
            )
            .foregroundStyle(
                isHovered && !isDisabled ?
                LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing) :
                LinearGradient(colors: [.primary, .primary], startPoint: .leading, endPoint: .trailing)
            )
            .scaleEffect(isHovered && !isDisabled ? 1.05 : 1.0)
            .shadow(color: isHovered && !isDisabled ? gradient[0].opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isHovered = hovering && !isDisabled
            }
        }
    }
}

// MARK: - Modern Stats Card
struct ModernStatsCard: View {
    let icon: String
    let gradient: [Color]
    let title: String
    let subtitle: String
    let description: String
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            center: .center,
                            startRadius: 15,
                            endRadius: 30
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(isHovered ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isHovered)
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(description)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .shadow(color: isHovered ? gradient[0].opacity(0.2) : .clear, radius: 15, x: 0, y: 8)
    }
}

// MARK: - Modern Toast View
struct ModernToastView: View {
    let message: String
    let type: ToastType
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(type.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(type.color)
                }
                
                Text(message)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case warning
    case info
    
    var color: Color {
        switch self {
        case .success: return AppColors.successGreen
        case .error: return AppColors.errorRed
        case .warning: return AppColors.warningOrange
        case .info: return AppColors.primaryBlue
        }
    }
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
}
