import SwiftUI

enum AboutTab: String, CaseIterable {
    case overview = "Overview"
    case features = "Features"
    case credits = "Credits"
    case license = "License"
    
    var icon: String {
        switch self {
        case .overview: return "info.circle.fill"
        case .features: return "star.fill"
        case .credits: return "heart.fill"
        case .license: return "doc.text.fill"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .overview: return [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)]
        case .features: return [.orange, .yellow]
        case .credits: return [.pink, .red]
        case .license: return [.green, .mint]
        }
    }
}

struct AboutView: View {
    @State private var selectedTab: AboutTab = .overview
    @State private var hoveredCard: String? = nil
    @State private var hoveredButton: String? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dynamic Background with Mesh Gradient
                backgroundGradient
                
                VStack(spacing: 0) {
                    // HERO HEADER with Glass Morphism
                    heroHeaderView
                    
                    // Custom Tab Selector with Vibrancy
                    customTabSelector
                    
                    // CONTENT AREA with Smooth Transitions
                    contentArea
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    
                    // FLOATING FOOTER
                    floatingFooterView
                }
            }
        }
        .frame(minWidth: 800, idealWidth: 900, maxWidth: .infinity, minHeight: 700, idealHeight: 800, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.08),
                    Color.cyan.opacity(0.06),
                    Color.pink.opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated mesh overlay
            RadialGradient(
                colors: [
                    selectedTab.gradient[0].opacity(0.15),
                    selectedTab.gradient[1].opacity(0.08),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 100,
                endRadius: 400
            )
            .animation(.easeInOut(duration: 1.2), value: selectedTab)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Compact Header
    private var heroHeaderView: some View {
        HStack(spacing: 16) {
            // Compact Title Section
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    // App Logo next to title - Using direct NSImage approach
                    AppLogoView(size: 32)
                    
                    Text("CleanME")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: selectedTab.gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundStyle(selectedTab.gradient[1])
                }
                
                Text("Professional Mac Cleaning & Optimization")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Version Badge
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                HStack(spacing: 4) {
                    Image(systemName: "tag.fill")
                        .font(.caption2)
                    Text("v\(version)")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.regularMaterial, in: Capsule())
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Custom Tab Selector
    private var customTabSelector: some View {
        HStack(spacing: 8) {
            ForEach(AboutTab.allCases, id: \.self) { tab in
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 16, weight: .medium))
                            .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                        
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            if selectedTab == tab {
                                // Active tab background
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.regularMaterial)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .strokeBorder(
                                                LinearGradient(
                                                    colors: tab.gradient.map { $0.opacity(0.6) },
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                    .shadow(color: tab.gradient[0].opacity(0.3), radius: 8, x: 0, y: 4)
                            } else {
                                // Inactive tab background
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                                    .opacity(0.6)
                            }
                        }
                    )
                    .foregroundStyle(
                        selectedTab == tab ?
                        LinearGradient(colors: tab.gradient, startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [.secondary, .secondary], startPoint: .leading, endPoint: .trailing)
                    )
                    .scaleEffect(selectedTab == tab ? 1.05 : 1.0)
                }
                .buttonStyle(.plain)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: selectedTab)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal, 40)
        .padding(.bottom, 5)
    }
    
    // MARK: - Content Area
    private var contentArea: some View {
        Group {
            switch selectedTab {
            case .overview:
                modernOverviewContent
            case .features:
                modernFeaturesContent
            case .credits:
                modernCreditsContent
            case .license:
                modernLicenseContent
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Simple Footer
    private var floatingFooterView: some View {
        HStack(spacing: 6) {
            Image(systemName: "c.circle.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 4) {
                Text("2025 CleanME - Built with")
                Text("❤️")
                Text("by Tariq Said")
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
    }
    
    
    // MARK: - Modern Overview Content
    private var modernOverviewContent: some View {
        VStack(spacing: 12) {
            // Hero Description Card
            modernGlassCard {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.blue.opacity(0.3),
                                        Color.cyan.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 8,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 18, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Professional Mac Optimization")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text("CleanME uses advanced algorithms to safely clean your Mac while maintaining system integrity.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // Feature Highlights Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                modernFeatureCard(
                    icon: "wand.and.stars.inverse",
                    gradient: [.blue, .cyan],
                    title: "Smart Clean",
                    subtitle: "AI-powered analysis",
                    description: "Advanced algorithms detect safe-to-remove files"
                )
                
                modernFeatureCard(
                    icon: "doc.on.clipboard.fill",
                    gradient: [.purple, .pink],
                    title: "Duplicate Finder",
                    subtitle: "Intelligent detection",
                    description: "Find and remove duplicate files"
                )
                
                modernFeatureCard(
                    icon: "shield.lefthalf.filled.badge.checkmark",
                    gradient: [.green, .mint],
                    title: "System Safe",
                    subtitle: "Protected cleaning",
                    description: "Never touches critical system files"
                )
                
                modernFeatureCard(
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    gradient: [.orange, .yellow],
                    title: "Performance",
                    subtitle: "Real-time monitoring",
                    description: "Track system improvements"
                )
                
                modernFeatureCard(
                    icon: "arrow.up.forward.app.fill",
                    gradient: [.indigo, .blue],
                    title: "GitHub",
                    subtitle: "Open Source",
                    description: "View source code and contribute"
                )
                
                modernFeatureCard(
                    icon: "globe.americas.fill",
                    gradient: [.red, .pink],
                    title: "Website",
                    subtitle: "Learn More",
                    description: "Visit our official website"
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func modernGlassCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private func modernFeatureCard(icon: String, gradient: [Color], title: String, subtitle: String, description: String) -> some View {
        Button(action: {
            if title == "GitHub" {
                if let url = URL(string: "https://github.com/tariqsaidofficial/CleanMe") {
                    NSWorkspace.shared.open(url)
                }
            } else if title == "Website" {
                if let url = URL(string: "https://portfolio.dxbmark.com/") {
                    NSWorkspace.shared.open(url)
                }
            }
        }) {
            VStack(spacing: 16) {
            // Icon with glow effect
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            center: .center,
                            startRadius: 20,
                            endRadius: 40
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)
                
                Circle()
                    .fill(.regularMaterial)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: gradient.map { $0.opacity(0.6) },
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(hoveredCard == title ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: hoveredCard)
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .onHover { isHovered in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                hoveredCard = isHovered ? title : nil
            }
        }
        .scaleEffect(hoveredCard == title ? 1.02 : 1.0)
        .shadow(color: hoveredCard == title ? gradient[0].opacity(0.2) : .clear, radius: 15, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Modern Features Content
    private var modernFeaturesContent: some View {
        VStack(spacing: 16) {
            // Features Header
            modernGlassCard {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.purple.opacity(0.3),
                                        Color.pink.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.purple, .pink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: selectedTab)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Powerful Features")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text("Everything you need for optimal Mac performance")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // Features List
            VStack(spacing: 16) {
                modernFeatureRow(
                    icon: "shield.lefthalf.filled.badge.checkmark",
                    gradient: [.green, .mint],
                    title: "Safe & Secure Cleaning",
                    description: "Advanced protection algorithms ensure system files remain untouched"
                )
                
                modernFeatureRow(
                    icon: "wand.and.stars.inverse",
                    gradient: [.blue, .cyan],
                    title: "Intelligent File Detection",
                    description: "AI-powered analysis identifies safe-to-remove files with precision"
                )
                
                modernFeatureRow(
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    gradient: [.orange, .yellow],
                    title: "Real-time Performance Monitoring",
                    description: "Track system improvements and storage optimization in real-time"
                )
                
                modernFeatureRow(
                    icon: "doc.on.clipboard.fill",
                    gradient: [.purple, .pink],
                    title: "Advanced Duplicate Detection",
                    description: "Find and remove duplicate files across your entire system"
                )
                
                modernFeatureRow(
                    icon: "macwindow.on.rectangle",
                    gradient: [.teal, .cyan],
                    title: "Native macOS Integration",
                    description: "Built with SwiftUI for optimal performance and system integration"
                )
            }
        }
    }
    
    private func modernFeatureRow(icon: String, gradient: [Color], title: String, description: String) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: gradient.map { $0.opacity(0.2) },
                            center: .center,
                            startRadius: 15,
                            endRadius: 30
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func modernCreditCard(icon: String, gradient: [Color], title: String, items: [String]) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: gradient.map { $0.opacity(0.2) },
                                center: .center,
                                startRadius: 15,
                                endRadius: 30
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            // Items
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(gradient[0].opacity(0.6))
                            .frame(width: 4, height: 4)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Modern License Content
    private var modernLicenseContent: some View {
        VStack(spacing: 16) {
            // License Header
            modernGlassCard {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.orange.opacity(0.3),
                                        Color.yellow.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 28, weight: .medium))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: selectedTab)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Open Source License")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text("Apache License 2.0 • Free & Open Source")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
            }
            
            // License Details
            VStack(spacing: 16) {
                modernLicenseCard(
                    icon: "checkmark.seal.fill",
                    gradient: [.green, .mint],
                    title: "Permissions",
                    items: [
                        "✓ Commercial use",
                        "✓ Modification",
                        "✓ Distribution",
                        "✓ Patent use"
                    ]
                )
                
                modernLicenseCard(
                    icon: "exclamationmark.triangle.fill",
                    gradient: [.orange, .yellow],
                    title: "Conditions",
                    items: [
                        "• License and copyright notice",
                        "• State changes",
                        "• Include original license"
                    ]
                )
                
                modernLicenseCard(
                    icon: "xmark.shield.fill",
                    gradient: [.red, .pink],
                    title: "Limitations",
                    items: [
                        "✗ Liability",
                        "✗ Warranty",
                        "✗ Trademark use"
                    ]
                )
            }
            
            // License Actions
            HStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/tariqsaidofficial/CleanMe/blob/main/LICENSE")!) {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text("View Full License")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.orange.opacity(0.6), .yellow.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .orange.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("Built with")
                        Text("❤️")
                        Text("by Tariq Said")
                    }
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    
                    Text("All rights reserved")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    // MARK: - Modern Credits Content
    private var modernCreditsContent: some View {
        VStack(spacing: 30) {
            // Partners Section - Side by Side
            HStack(spacing: 20) {
                // Developer Section
                modernCreditsSection(
                    title: "Developer",
                    subtitle: "Built with ❤️ by",
                    logoName: "TariqSaid-logo",
                    name: "Tariq Said",
                    description: "Full-Stack Developer & UI/UX Designer",
                    websiteURL: "https://portfolio.dxbmark.com/",
                    gradient: [.blue, .purple]
                )
                
                // Agency Section
                modernCreditsSection(
                    title: "Agency Partner",
                    subtitle: "In collaboration with",
                    logoName: "mwheba-Logo",
                    name: "MWHEBA Agency",
                    description: "Digital Solutions & Creative Agency",
                    websiteURL: "https://mwheba.com/",
                    gradient: [.orange, .red]
                )
            }
            
            // Credits Grid - Acknowledgments, Technologies, etc.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                modernCreditCard(
                    icon: "person.fill",
                    gradient: [.blue, Color(red: 0.4, green: 0.6, blue: 1.0)],
                    title: "Development Team",
                    items: [
                        "Tariq Said - Lead Developer",
                        "UI/UX Design & Implementation",
                        "Core Engine Development"
                    ]
                )
                
                modernCreditCard(
                    icon: "hammer.circle.fill",
                    gradient: [.orange, .yellow],
                    title: "Technologies",
                    items: [
                        "Swift 6.0 & SwiftUI",
                        "macOS SDK 15.0+",
                        "FileManager & Foundation APIs"
                    ]
                )
                
                modernCreditCard(
                    icon: "wrench.and.screwdriver.fill",
                    gradient: [.green, .mint],
                    title: "Development Tools",
                    items: [
                        "Xcode 16",
                        "Swift Package Manager",
                        "Git & GitHub Actions"
                    ]
                )
                
                modernCreditCard(
                    icon: "paintbrush.fill",
                    gradient: [.purple, .pink],
                    title: "Design System",
                    items: [
                        "SF Symbols 6",
                        "macOS Human Interface Guidelines",
                        "Glass Morphism & Vibrancy Effects"
                    ]
                )
            }
            
        }
        .padding(.vertical, 20)
    }
    
    private func modernCreditsSection(title: String, subtitle: String, logoName: String, name: String, description: String, websiteURL: String, gradient: [Color]) -> some View {
        VStack(spacing: 12) {
            // Section Header - أصغر
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Credit Card - أصغر
            VStack(spacing: 12) {
                // Logo محلي
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: gradient.map { $0.opacity(0.1) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
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
                    
                    // Try multiple paths to find the logo
                    if let logoImage = loadLogoImage(named: logoName) {
                        Image(nsImage: logoImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        // Fallback icon
                        Image(systemName: name.contains("Agency") ? "building.2.fill" : "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                VStack(spacing: 6) {
                    Text(name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Website Button - أصغر
                    Button(action: {
                        if let url = URL(string: websiteURL) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                            Text("Visit Website")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(hoveredButton == name ? 1.05 : 1.0)
                    .onHover { hovering in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            hoveredButton = hovering ? name : nil
                        }
                    }
                }
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Logo Loading Helper
    private func loadLogoImage(named logoName: String) -> NSImage? {
        // Try different paths to find the logo
        let possiblePaths = [
            logoName,  // Direct name
            "Images/\(logoName)",  // In Images folder
            "\(logoName).png",  // With extension
            "Images/\(logoName).png"  // In Images folder with extension
        ]
        
        for path in possiblePaths {
            // Try Bundle.main.image first
            if let image = Bundle.main.image(forResource: path) {
                return image
            }
            
            // Try Bundle.main.path
            if let imagePath = Bundle.main.path(forResource: path, ofType: nil),
               let image = NSImage(contentsOfFile: imagePath) {
                return image
            }
            
            // Try with png extension
            if let imagePath = Bundle.main.path(forResource: path, ofType: "png"),
               let image = NSImage(contentsOfFile: imagePath) {
                return image
            }
        }
        
        // Debug: Print available resources
        if let resourcePath = Bundle.main.resourcePath {
            print("🔍 Bundle resource path: \(resourcePath)")
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                print("🔍 Available resources: \(contents)")
            }
        }
        
        return nil
    }
    
    private func modernLicenseCard(icon: String, gradient: [Color], title: String, items: [String]) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: gradient.map { $0.opacity(0.2) },
                                center: .center,
                                startRadius: 15,
                                endRadius: 30
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 8) {
                        Text(item)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
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

// MARK: - App Logo View
struct AppLogoView: View {
    let size: CGFloat
    
    var body: some View {
        Group {
            // Try to load from different sources
            if let logoPath = Bundle.main.path(forResource: "Assets.xcassets/LogoLarge.imageset/logo@2x", ofType: "png"),
               let nsImage = NSImage(contentsOfFile: logoPath) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .onAppear {
                        print("✅ SUCCESS: Loaded logo from nested path!")
                    }
            } else if let logoURL = Bundle.main.url(forResource: "AppIcon", withExtension: "png"),
                      let nsImage = NSImage(contentsOf: logoURL) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .onAppear {
                        print("✅ SUCCESS: Loaded AppIcon.png!")
                    }
            } else {
                // Create a custom logo using SF Symbols and gradients - YOUR LOGO STYLE
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.2, green: 0.6, blue: 1.0),  // Nice blue
                                    Color(red: 0.0, green: 0.8, blue: 1.0)   // Cyan
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)
                        .overlay(
                            RoundedRectangle(cornerRadius: size * 0.22)
                                .stroke(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                    
                    // Stack of cleaning elements
                    VStack(spacing: size * 0.05) {
                        // Top sparkle
                        Image(systemName: "sparkles")
                            .font(.system(size: size * 0.25, weight: .medium))
                            .foregroundStyle(.white.opacity(0.9))
                        
                        // Main cleaning icon
                        Image(systemName: "rectangle.stack.fill")
                            .font(.system(size: size * 0.35, weight: .medium))
                            .foregroundStyle(.white)
                    }
                }
                .shadow(color: .blue.opacity(0.4), radius: size * 0.15, x: 0, y: size * 0.08)
                .onAppear {
                    print("⚠️ Using custom fallback logo (original logo not found)")
                }
            }
        }
    }
}

// MARK: - Preview
struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
