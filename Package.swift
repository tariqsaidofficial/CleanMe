// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CleanME",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CleanME",
            targets: ["CleanME"]
        ),
    ],
    dependencies: [
        // SwiftUI and modern macOS features require macOS 13.0+
        // Add future dependencies here as needed
        // .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.4.2"),
    ],
    targets: [
        .executableTarget(
            name: "CleanME",
            dependencies: [
                // "Sparkle" // For future auto-update functionality
            ],
            path: "Sources/CleanME",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-upcoming-feature", "-Xfrontend", "BareSlashRegexLiterals"])
            ],
            linkerSettings: [
                .linkedFramework("SwiftUI"),
                .linkedFramework("AppKit")
            ]
        ),
        .testTarget(
            name: "CleanMETests",
            dependencies: ["CleanME"],
            path: "Tests/CleanMETests"
        ),
    ]
)