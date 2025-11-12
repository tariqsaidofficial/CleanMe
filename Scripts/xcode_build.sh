#!/bin/bash
# Xcode Run Script - Post Build

echo "🔨 Creating app bundle for Xcode..."

# Get the built executable path
EXECUTABLE="${BUILT_PRODUCTS_DIR}/${EXECUTABLE_NAME}"
APP_BUNDLE="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

# Create app bundle structure
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Create Info.plist
cat > "${APP_BUNDLE}/Contents/Info.plist" << 'EOF'
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
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Copy executable
if [ -f "$EXECUTABLE" ]; then
    cp "$EXECUTABLE" "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"
    chmod +x "${APP_BUNDLE}/Contents/MacOS/${EXECUTABLE_NAME}"
fi

echo "✅ App bundle created!"
