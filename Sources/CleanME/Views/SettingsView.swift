import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var showingResetAlert = false
    
    var body: some View {
        TabView {
            generalSettingsTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
            
            scanSettingsTab
                .tabItem {
                    Label("Scan", systemImage: "magnifyingglass")
                }
            
            securitySettingsTab
                .tabItem {
                    Label("Security", systemImage: "shield")
                }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private var generalSettingsTab: some View {
        Form {
            Section("General Settings") {
                Toggle("Enable Logging", isOn: $appSettings.enableLogging)
                
                Picker("Log Level", selection: $appSettings.logLevel) {
                    ForEach(LogLevel.allCases, id: \.self) { level in
                        Text(level.rawValue).tag(level)
                    }
                }
                
                Toggle("Confirm Before Delete", isOn: $appSettings.confirmBeforeDelete)
                Toggle("Show File Preview", isOn: $appSettings.showFilePreview)
            }
            
            Section("Performance") {
                Toggle("Auto Refresh Results", isOn: $appSettings.autoRefreshResults)
            }
            
            Section("Actions") {
                Button("Reset Settings") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
            }
        }
        .alert("Reset Settings", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                appSettings.resetToDefaults()
            }
        } message: {
            Text("All settings will be reset to default values")
        }
        .padding()
    }
    
    private var scanSettingsTab: some View {
        Form {
            Section("File Types") {
                Toggle("Cache Files", isOn: $appSettings.scanCache)
                Toggle("Log Files", isOn: $appSettings.scanLogs)
                Toggle("Temporary Files", isOn: $appSettings.scanTempFiles)
                Toggle("Trash Bin", isOn: $appSettings.scanTrash)
            }
            
            Section("Scan Limits") {
                HStack {
                    Text("Minimum File Age (days)")
                    Spacer()
                    TextField("", value: $appSettings.maxFileAge, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                
                HStack {
                    Text("Minimum File Size (bytes)")
                    Spacer()
                    TextField("", value: $appSettings.minFileSize, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
            }
        }
        .padding()
    }
    
    private var securitySettingsTab: some View {
        Form {
            Section("Security") {
                Toggle("Safe Mode", isOn: $appSettings.enableSafeMode)
                    .help("Prevents deletion of critical system files")
                
                Toggle("Require Admin Password for System Files", isOn: $appSettings.requireAdminForSystemFiles)
                
                Toggle("Create Backup Before Delete", isOn: $appSettings.createBackupBeforeDelete)
            }
            
            Section("Exclusions") {
                VStack(alignment: .leading) {
                    Text("Excluded Paths:")
                    List {
                        ForEach(appSettings.excludedPaths, id: \.self) { path in
                            Text(path)
                        }
                    }
                    .frame(height: 100)
                    
                    Button("Add Path") {
                        // Add path functionality
                    }
                }
            }
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

