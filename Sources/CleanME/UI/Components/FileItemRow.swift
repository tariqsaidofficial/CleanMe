import SwiftUI

struct FileItemRow: View {
    let item: CleanupItem
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            // File icon
            Image(systemName: item.systemIcon)
                .foregroundColor(item.iconColor)
                .font(.title2)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                // File name
                Text(item.fileName)
                    .font(.body)
                    .lineLimit(1)
                
                // File path
                Text(item.filePath)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                // File size
                Text(formatBytes(item.fileSize))
                    .font(.body)
                    .fontWeight(.medium)
                
                // Last modified
                Text(item.lastModified.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct FileItemRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            FileItemRow(
                item: CleanupItem(
                    fileName: "cache.db",
                    filePath: "/Users/user/Library/Caches/com.example.app/cache.db",
                    fileSize: 1024000,
                    fileType: .cache,
                    lastModified: Date(),
                    isProtected: false
                ),
                isSelected: false
            ) {
                // Toggle action
            }
        }
    }
}