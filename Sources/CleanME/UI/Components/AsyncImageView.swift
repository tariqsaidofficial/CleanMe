import SwiftUI

// MARK: - Async Image Loader for Remote Logos
struct AsyncImageView: View {
    let url: String
    let placeholder: String
    let size: CGSize
    let gradient: [Color]
    
    @State private var image: NSImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                // Placeholder with gradient background
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.1) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size.width, height: size.height)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: gradient.map { $0.opacity(0.3) },
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        // Fallback icon
                        Image(systemName: placeholder)
                            .font(.system(size: size.width * 0.5))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let imageURL = URL(string: url) else {
            isLoading = false
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                
                await MainActor.run {
                    if let nsImage = NSImage(data: data) {
                        self.image = nsImage
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview
struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AsyncImageView(
                url: "https://portfolio.dxbmark.com/TariqSaid-logo.webp",
                placeholder: "person.circle.fill",
                size: CGSize(width: 80, height: 80),
                gradient: [.blue, .purple]
            )
            
            AsyncImageView(
                url: "https://mwheba.com/wp-content/uploads/2025/07/Logo-Wide-Inverted-e1754726255278.png",
                placeholder: "building.2.fill",
                size: CGSize(width: 80, height: 80),
                gradient: [.orange, .red]
            )
        }
        .padding()
    }
}
