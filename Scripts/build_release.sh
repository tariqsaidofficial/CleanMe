#!/bin/bash

set -e

echo "🚀 Building CleanME for Production..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build/release
rm -rf CleanME.app

# Build with Swift Package Manager
echo "🔨 Building executable..."
swift build -c release

# Create app bundle structure
echo "📦 Creating app bundle..."
mkdir -p CleanME.app/Contents/{MacOS,Resources}

# Copy executable
cp .build/release/CleanME CleanME.app/Contents/MacOS/CleanME

# Compile Asset Catalog with actool (includes Dark Mode support)
echo "🎨 Compiling Asset Catalog (with Dark Mode icons)..."
xcrun actool Sources/CleanME/Resources/Assets.xcassets \
  --compile CleanME.app/Contents/Resources \
  --platform macosx \
  --minimum-deployment-target 13.0 \
  --app-icon AppIcon \
  --output-partial-info-plist /tmp/CleanME-partial.plist \
  --compress-pngs

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > CleanME.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.dxbmark.cleanme</string>
    <key>CFBundleName</key>
    <string>CleanME</string>
    <key>CFBundleDisplayName</key>
    <string>CleanME</string>
    <key>CFBundleExecutable</key>
    <string>CleanME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSUserNotificationAlertStyle</key>
    <string>alert</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
</dict>
</plist>
EOF

# Copy VERSION file
cp VERSION CleanME.app/Contents/Resources/VERSION

# Copy other resources (if needed)
if [ -d "Sources/CleanME/Resources" ]; then
    echo "📂 Copying additional resources..."
    # Don't copy Assets.xcassets (already compiled)
    find Sources/CleanME/Resources -type f ! -path "*/Assets.xcassets/*" -exec cp {} CleanME.app/Contents/Resources/ \; 2>/dev/null || true
fi

echo ""
echo "✅ Production build complete!"
echo "📍 Location: $(pwd)/CleanME.app"
echo ""
echo "🎨 Dark Mode Icon: ✅ Supported"
echo "   - Light mode icon: Included"
echo "   - Dark mode icon: Included"
echo ""
echo "🔍 To verify:"
echo "   1. Open CleanME.app"
echo "   2. Toggle System Appearance (Light/Dark)"
echo "   3. Icon in Dock should change"
echo ""
echo "📦 To create DMG:"
echo "   ./create_dmg.sh"
echo ""
echo "🔐 To code sign (for distribution):"
echo "   codesign --force --deep --sign \"Developer ID Application: Your Name\" CleanME.app"
echo ""
