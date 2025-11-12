#!/bin/bash
set -e

echo "🔨 Building CleanME..."
swift build

echo "📦 Creating app bundle..."
mkdir -p .build/debug/CleanME.app/Contents/{MacOS,Resources}

# Copy executable
cp .build/debug/CleanME .build/debug/CleanME.app/Contents/MacOS/

# Copy logo to app bundle resources
echo "🎨 Adding app logo..."
if [ -f "Sources/CleanME/Resources/Assets.xcassets/LogoLarge.imageset/logo@2x.png" ]; then
    # Copy as AppIcon.png for the app icon
    cp "Sources/CleanME/Resources/Assets.xcassets/LogoLarge.imageset/logo@2x.png" ".build/debug/CleanME.app/Contents/Resources/AppIcon.png"
    
    # Create the nested directory structure for direct access
    mkdir -p ".build/debug/CleanME.app/Contents/Resources/Assets.xcassets/LogoLarge.imageset/"
    cp "Sources/CleanME/Resources/Assets.xcassets/LogoLarge.imageset/logo@2x.png" ".build/debug/CleanME.app/Contents/Resources/Assets.xcassets/LogoLarge.imageset/logo@2x.png"
    
    echo "✅ Logo added to app bundle (both locations)"
else
    echo "⚠️  Logo file not found"
fi

# Copy all assets
echo "📁 Copying assets..."
if [ -d "Sources/CleanME/Resources" ]; then
    cp -r "Sources/CleanME/Resources/"* ".build/debug/CleanME.app/Contents/Resources/"
    echo "✅ Assets copied to app bundle"
fi

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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

echo "✅ App bundle created at: .build/debug/CleanME.app"

echo "🚀 Launching app..."
open .build/debug/CleanME.app

echo "✨ Done! Check your Dock for the CleanME icon!"
