import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo
            Image("LogoLarge")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
                .shadow(radius: 4)
            
            // App Name and Version
            VStack(spacing: 8) {
                Text("CleanME")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version \(Bundle.main.appVersion)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Description
            VStack(spacing: 12) {
                Text("macOS System Cleaner")
                    .font(.headline)
                
                Text("Free up disk space by removing unnecessary files")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.vertical, 8)
            
            // Features
            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "trash.fill", text: "Clean cache, logs & temporary files")
                featureRow(icon: "doc.on.doc.fill", text: "Find and remove duplicate files")
                featureRow(icon: "folder.fill", text: "Identify large files & empty folders")
                featureRow(icon: "shield.checkmark.fill", text: "Safe deletion with system protection")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Links
            HStack(spacing: 20) {
                Link(destination: URL(string: "https://github.com")!) {
                    Label("GitHub", systemImage: "arrow.up.forward.app")
                }
                .buttonStyle(.bordered)
                
                Link(destination: URL(string: "https://github.com")!) {
                    Label("Website", systemImage: "globe")
                }
                .buttonStyle(.bordered)
                
                Button {
                    NSWorkspace.shared.open(URL(string: "https://github.com")!)
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
                .buttonStyle(.bordered)
            }
            
            // Copyright
            Text("© 2025 CleanME. All rights reserved.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

// MARK: - Bundle Extension
extension Bundle {
    var appVersion: String {
        return (infoDictionary?["CFBundleShortVersionString"] as? String) ?? "1.0.0"
    }
    
    var appBuild: String {
        return (infoDictionary?["CFBundleVersion"] as? String) ?? "1"
    }
}

// MARK: - Preview
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
