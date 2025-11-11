import SwiftUI
import AppKit

struct AboutView: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            // App Icon
            Group {
                if let resourcePath = Bundle.main.resourcePath,
                   let logoImage = NSImage(contentsOfFile: resourcePath + "/CleanME_CleanME.bundle/logo-large.png") {
                    Image(nsImage: logoImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 96, height: 96)
                        .shadow(radius: 8)
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .cyan.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 96)
                        
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .shadow(radius: 8)
                }
            }
            
            // App Name and Version
            Text("CleanME v\(Bundle.main.appVersion)")
                .font(.title3)
                .fontWeight(.semibold)
            
            // Description
            Text("macOS System Cleaner")
                .font(.body)
                .foregroundColor(.secondary)
            
            Spacer()
            
            // Copyright
            Text("© 2025 CleanME. All rights reserved.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            // Links
            HStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/tariqsaidofficial/CleanMe")!) {
                    Label("GitHub", systemImage: "arrow.up.forward.app")
                }
                .buttonStyle(.bordered)
                
                Button {
                    NSWorkspace.shared.open(URL(string: "https://github.com/tariqsaidofficial/CleanMe")!)
                } label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
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
