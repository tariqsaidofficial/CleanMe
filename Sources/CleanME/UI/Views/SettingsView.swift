import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingResetAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Appearance Section
                settingsSection(
                    icon: "paintbrush.fill",
                    iconColor: .purple,
                    title: "Appearance"
                ) {
                    HStack(spacing: 12) {
                        ForEach(ThemeManager.Theme.allCases, id: \.self) { theme in
                            themeCard(theme: theme)
                        }
                    }
                }
                
                // General Section
                settingsSection(
                    icon: "gearshape.fill",
                    iconColor: .blue,
                    title: "General"
                ) {
                    VStack(spacing: 16) {
                        settingToggle(
                            title: "Enable Logging",
                            description: "Record app activities for debugging",
                            icon: "doc.text.fill",
                            binding: $appSettings.enableLogging
                        )
                        
                        Divider()
                        
                        settingToggle(
                            title: "Confirm Before Delete",
                            description: "Show confirmation dialog before deleting files",
                            icon: "exclamationmark.triangle.fill",
                            binding: $appSettings.confirmBeforeDelete
                        )
                        
                        Divider()
                        
                        settingToggle(
                            title: "Show File Preview",
                            description: "Display file details in results",
                            icon: "eye.fill",
                            binding: $appSettings.showFilePreview
                        )
                        
                        Divider()
                        
                        settingToggle(
                            title: "Auto Refresh Results",
                            description: "Automatically update scan results",
                            icon: "arrow.clockwise",
                            binding: $appSettings.autoRefreshResults
                        )
                        
                        Divider()
                        
                        settingToggle(
                            title: "Enable Haptic Feedback",
                            description: "Feel vibrations for actions",
                            icon: "hand.tap.fill",
                            binding: $appSettings.enableHapticFeedback
                        )
                    }
                }
                
                // Security Section
                settingsSection(
                    icon: "shield.fill",
                    iconColor: .green,
                    title: "Security"
                ) {
                    VStack(spacing: 16) {
                        settingToggle(
                            title: "Safe Mode",
                            description: "Prevent deletion of critical system files",
                            icon: "lock.shield.fill",
                            binding: $appSettings.enableSafeMode
                        )
                        
                        Divider()
                        
                        settingToggle(
                            title: "Require Admin for System Files",
                            description: "Ask for password when deleting system files",
                            icon: "key.fill",
                            binding: $appSettings.requireAdminForSystemFiles
                        )
                        
                        Divider()
                        
                        settingToggle(
                            title: "Create Backup Before Delete",
                            description: "Keep a copy before removing files",
                            icon: "archivebox.fill",
                            binding: $appSettings.createBackupBeforeDelete
                        )
                    }
                }
                
                // Reset Section
                Button(action: { showingResetAlert = true }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset All Settings")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .frame(minWidth: 700, idealWidth: 800, maxWidth: .infinity, minHeight: 600, idealHeight: 750, maxHeight: .infinity)
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appSettings.resetToDefaults()
            }
        } message: {
            Text("All settings will be reset to default values. This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Views
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppSettings())
            .environmentObject(ThemeManager.shared)
    }
}

