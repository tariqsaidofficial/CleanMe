import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingResetAlert = false
    @State private var hoveredCard: String? = nil
    @State private var hoveredButton: String? = nil
    
    var body: some View {
        ZStack {
            // Dynamic Background with Mesh Gradient
            backgroundGradient
            
            VStack(spacing: 0) {
                // Modern Header
                modernHeaderView
                
                // Modern Settings Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Modern Appearance Section
                        modernSettingsSection(
                            icon: "paintbrush.fill",
                            gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                            title: "Appearance",
                            subtitle: "Customize the look and feel"
                        ) {
                            modernThemeSelector
                        }
                        
                        // Modern General Section
                        modernSettingsSection(
                            icon: "gearshape.fill",
                            gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                            title: "General",
                            subtitle: "App behavior and preferences"
                        ) {
                            VStack(spacing: 16) {
                                modernSettingToggle(
                                    title: "Enable Logging",
                                    description: "Record app activities for debugging",
                                    icon: "doc.text.fill",
                                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    binding: $appSettings.enableLogging
                                )
                                
                                modernSettingToggle(
                                    title: "Confirm Before Delete",
                                    description: "Show confirmation dialog before deleting files",
                                    icon: "exclamationmark.triangle.fill",
                                    gradient: [.orange, .yellow], // Keep warning colors
                                    binding: $appSettings.confirmBeforeDelete
                                )
                                
                                modernSettingToggle(
                                    title: "Show File Preview",
                                    description: "Display file details in results",
                                    icon: "eye.fill",
                                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    binding: $appSettings.showFilePreview
                                )
                                
                                modernSettingToggle(
                                    title: "Auto Refresh Results",
                                    description: "Automatically update scan results",
                                    icon: "arrow.clockwise",
                                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    binding: $appSettings.autoRefreshResults
                                )
                                
                                modernSettingToggle(
                                    title: "Enable Haptic Feedback",
                                    description: "Feel vibrations for actions",
                                    icon: "hand.tap.fill",
                                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    binding: $appSettings.enableHapticFeedback
                                )
                            }
                        }
                        
                        // Modern Security Section
                        modernSettingsSection(
                            icon: "shield.fill",
                            gradient: [.green, .mint], // Keep success colors for security
                            title: "Security",
                            subtitle: "Protect your system and data"
                        ) {
                            VStack(spacing: 16) {
                                modernSettingToggle(
                                    title: "Safe Mode",
                                    description: "Prevent deletion of critical system files",
                                    icon: "lock.shield.fill",
                                    gradient: [.green, .mint], // Keep success colors
                                    binding: $appSettings.enableSafeMode
                                )
                                
                                modernSettingToggle(
                                    title: "Require Admin for System Files",
                                    description: "Ask for password when deleting system files",
                                    icon: "key.fill",
                                    gradient: [Color(red: 0.8, green: 0.2, blue: 0.3), Color(red: 0.6, green: 0.1, blue: 0.2)], // Maroon red for critical
                                    binding: $appSettings.requireAdminForSystemFiles
                                )
                                
                                modernSettingToggle(
                                    title: "Create Backup Before Delete",
                                    description: "Keep a copy before removing files",
                                    icon: "archivebox.fill",
                                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    binding: $appSettings.createBackupBeforeDelete
                                )
                            }
                        }
                        
                        // Modern Reset Section
                        modernResetButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(minWidth: 800, idealWidth: 900, maxWidth: .infinity, minHeight: 700, idealHeight: 800, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appSettings.resetToDefaults()
            }
        } message: {
            Text("All settings will be reset to default values. This action cannot be undone.")
        }
    }
    
    // MARK: - Dynamic Background
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.05),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated mesh overlay
            RadialGradient(
                colors: [
                    Color.blue.opacity(0.15),
                    Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .animation(.easeInOut(duration: 1.2), value: themeManager.current)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Modern Header View
    private var modernHeaderView: some View {
        VStack(spacing: 16) {
            // Header Title with Logo
            HStack(spacing: 12) {
                AppLogoView(size: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Customize your CleanME experience")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - Modern Settings Section
    private func modernSettingsSection<Content: View>(
        icon: String,
        gradient: [Color],
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
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
            
            // Section Content
            content()
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Modern Theme Selector
    private var modernThemeSelector: some View {
        HStack(spacing: 16) {
            ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                modernThemeCard(theme: theme)
            }
        }
    }
    
    // MARK: - Modern Theme Card
    private func modernThemeCard(theme: ThemeManager.Theme) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                themeManager.current = theme
                FeedbackManager.shared.selection()
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(theme == .light ? Color.white : theme == .dark ? Color.black : Color.gray.opacity(0.3))
                        .frame(height: 80)
                    
                    if theme == .system {
                        HStack(spacing: 0) {
                            Color.white
                            Color.black
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .frame(height: 80)
                    }
                    
                    // Selection indicator
                    if themeManager.current == theme {
                        ZStack {
                            Circle()
                                .fill(.blue.opacity(0.2))
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            themeManager.current == theme ?
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [.clear, .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
                
                Text(theme.displayName)
                    .font(.caption)
                    .fontWeight(themeManager.current == theme ? .semibold : .medium)
                    .foregroundStyle(themeManager.current == theme ? .blue : .primary)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(hoveredCard == theme.displayName ? 1.02 : 1.0)
            .shadow(color: hoveredCard == theme.displayName ? .blue.opacity(0.2) : .clear, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                hoveredCard = isHovered ? theme.displayName : nil
            }
        }
    }
    
    // MARK: - Modern Setting Toggle
    private func modernSettingToggle(
        title: String,
        description: String,
        icon: String,
        gradient: [Color],
        binding: Binding<Bool>
    ) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            center: .center,
                            startRadius: 12,
                            endRadius: 24
                        )
                    )
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Toggle("", isOn: binding)
                .labelsHidden()
                .toggleStyle(ModernToggleStyle(gradient: gradient))
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Modern Reset Button
    private var modernResetButton: some View {
        Button(action: { showingResetAlert = true }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.red.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.red)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reset All Settings")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("Restore default configuration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(20)
            .background(.red.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.red.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(hoveredButton == "reset" ? 1.02 : 1.0)
            .shadow(color: hoveredButton == "reset" ? .red.opacity(0.2) : .clear, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
        .onHover { isHovered in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                hoveredButton = isHovered ? "reset" : nil
            }
        }
    }
    
    // MARK: - Helper Views (Old)
    @ViewBuilder
    private func settingsSection<Content: View>(
        icon: String,
        iconColor: Color,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private func themeCard(theme: ThemeManager.Theme) -> some View {
        Button(action: {
            themeManager.current = theme
            FeedbackManager.shared.selection()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(theme == .light ? Color.white : theme == .dark ? Color.black : Color.gray.opacity(0.3))
                        .frame(height: 60)
                    
                    if theme == .system {
                        HStack(spacing: 0) {
                            Color.white
                            Color.black
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(height: 60)
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(themeManager.current == theme ? Color.blue : Color.clear, lineWidth: 3)
                )
                
                Text(theme.displayName)
                    .font(.caption)
                    .fontWeight(themeManager.current == theme ? .semibold : .regular)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func settingToggle(
        title: String,
        description: String,
        icon: String,
        binding: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.secondary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: binding)
                .labelsHidden()
        }
    }
}

// MARK: - Modern Toggle Style
struct ModernToggleStyle: ToggleStyle {
    let gradient: [Color]
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            ZStack {
                // Background track
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? 
                          LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing) :
                          LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(width: 50, height: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
                    )
                
                // Toggle thumb
                Circle()
                    .fill(.white)
                    .frame(width: 26, height: 26)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .offset(x: configuration.isOn ? 10 : -10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
            }
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppSettings())
            .environmentObject(ThemeManager.shared)
    }
}

