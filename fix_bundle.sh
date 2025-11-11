#!/bin/bash

# Create a proper Info.plist in the right location
mkdir -p .build/debug/CleanME.app/Contents
cat > .build/debug/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.cleanme.app</string>
    <key>CFBundleName</key>
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
</dict>
</plist>
PLIST

# Create app bundle structure
mkdir -p .build/debug/CleanME.app/Contents/MacOS
mkdir -p .build/debug/CleanME.app/Contents/Resources

# Copy executable
cp .build/arm64-apple-macosx/debug/CleanME .build/debug/CleanME.app/Contents/MacOS/

# Copy Info.plist
cp .build/debug/Info.plist .build/debug/CleanME.app/Contents/

echo "App bundle created!"
ls -la .build/debug/CleanME.app/Contents/
