#!/bin/bash
set -e

echo "🔨 Building CleanME..."
swift build

echo "📦 Creating app bundle..."
mkdir -p .build/debug/CleanME.app/Contents/{MacOS,Resources}

# Create Info.plist
cat > .build/debug/CleanME.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.cleanme.app</string>
    <key>CFBundleName</key>
    <string>CleanME</string>
    <key>CFBundleExecutable</key>
    <string>CleanME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Copy executable
cp .build/arm64-apple-macosx/debug/CleanME .build/debug/CleanME.app/Contents/MacOS/CleanME

# Copy resources
if [ -d "Sources/CleanME/Resources/Assets.xcassets" ]; then
    cp -r Sources/CleanME/Resources/Assets.xcassets .build/debug/CleanME.app/Contents/Resources/
fi

echo "✅ App bundle created at: .build/debug/CleanME.app"
echo "🚀 Launching app..."

# Launch the app
open .build/debug/CleanME.app

echo "✨ Done! Check your Dock for the CleanME icon!"
