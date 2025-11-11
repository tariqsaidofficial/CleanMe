import SwiftUI

struct ShortcutOverlayView: View {
    let shortcuts: [(key: String, description: String)] = [
        ("⌘ N", "Start New Scan"),
        ("⌘ R", "Refresh Results"),
        ("⌘ D", "Delete Selected"),
        ("⌘ E", "Export Results"),
        ("⌘ ,", "Open Settings"),
        ("⌘ A", "Select All"),
        ("⌘ /", "Show Shortcuts"),
        ("⌘ W", "Close Window"),
        ("⌘ Q", "Quit Application")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "keyboard")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Keyboard Shortcuts")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.bottom, 8)
                
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(shortcuts, id: \.key) { shortcut in
                            HStack {
                                Text(shortcut.key)
                                    .font(.system(.body, design: .monospaced))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(6)
                                    .frame(width: 80, alignment: .leading)
                                
                                Text(shortcut.description)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                        }
                    }
                }
                .frame(maxHeight: 300)
                
                Divider()
                
                Text("Press ⌘ / again to close")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(24)
            .frame(width: 400)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
    }
}
