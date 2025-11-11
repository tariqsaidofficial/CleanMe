import SwiftUI

struct SaveDocumentView: View {
    @State private var name = ""
    @State private var location = "Desktop"
    @Environment(\.dismiss) private var dismiss
    
    var onSave: ((String, String) -> Void)?
    var onDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Do you want to keep this scan result?")
                .font(.headline)
            
            Text("You can choose to save your scan results or delete them immediately. This action cannot be undone.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            TextField("Untitled", text: $name)
                .textFieldStyle(.roundedBorder)
            
            Picker("Where:", selection: $location) {
                Text("Desktop").tag("Desktop")
                Text("Documents").tag("Documents")
                Text("Downloads").tag("Downloads")
            }
            
            HStack {
                Button("Delete", role: .destructive) {
                    onDelete?()
                    dismiss()
                }
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Save") {
                    onSave?(name, location)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 480, height: 260)
        .background(Material.thick)
        .cornerRadius(20)
    }
}
