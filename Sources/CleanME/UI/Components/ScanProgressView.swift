import SwiftUI

struct ScanProgressView: View {
    @Binding var progress: Double
    var label: String

    var body: some View {
        VStack {
            Text(label)
                .font(.headline)
                .padding(.bottom, 5)
            SwiftUI.ProgressView(value: progress, total: 100)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(height: 20)
                .padding()
        }
        .padding()
    }
}

struct ScanProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ScanProgressView(progress: .constant(50), label: "Cleaning...")
            .previewLayout(.sizeThatFits)
    }
}