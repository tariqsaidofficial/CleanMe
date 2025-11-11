import SwiftUI

struct ProgressView: View {
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

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(progress: .constant(50), label: "Cleaning...")
            .previewLayout(.sizeThatFits)
    }
}