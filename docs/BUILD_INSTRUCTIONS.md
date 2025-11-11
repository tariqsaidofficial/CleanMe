# 🚀 Build Instructions for Production

## ⚠️ Current Limitation

The current `run_app.sh` script is for **development only**. For production builds (App Store, DMG distribution), you need to use Xcode.

## 📦 Production Build Steps

### Option 1: Using Xcode (Recommended)

1. **Open in Xcode:**
   ```bash
   open Package.swift
   ```

2. **Configure Asset Catalog:**
   - In Xcode, go to Project Settings
   - Select "CleanME" target
   - Under "General" → "App Icon"
   - Set to: `AppIcon` (from Assets.xcassets)

3. **Build Settings:**
   - Set `ASSETCATALOG_COMPILER_APPICON_NAME` to `AppIcon`
   - Enable `ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS`

4. **Build for Release:**
   ```bash
   xcodebuild -scheme CleanME -configuration Release
   ```

### Option 2: Using Swift Package Manager + Manual Steps

1. **Build the executable:**
   ```bash
   swift build -c release
   ```

2. **Create app bundle:**
   ```bash
   mkdir -p CleanME.app/Contents/{MacOS,Resources}
   cp .build/release/CleanME CleanME.app/Contents/MacOS/
   ```

3. **Compile Asset Catalog:**
   ```bash
   xcrun actool Sources/CleanME/Resources/Assets.xcassets \
     --compile CleanME.app/Contents/Resources \
     --platform macosx \
     --minimum-deployment-target 13.0 \
     --app-icon AppIcon \
     --output-partial-info-plist /tmp/partial.plist
   ```

4. **Create Info.plist:**
   ```bash
   cp Info.plist CleanME.app/Contents/Info.plist
   ```

5. **Code Sign (for distribution):**
   ```bash
   codesign --force --deep --sign "Developer ID Application: Your Name" CleanME.app
   ```

## 🎨 Dark Mode App Icon

The app icon **WILL** support Dark Mode in production if:

1. ✅ Asset Catalog has both light and dark variants
2. ✅ `actool` compiles the catalog correctly
3. ✅ Info.plist references the Asset Catalog

### Current Status:
- ✅ Asset Catalog configured (`AppIcon.appiconset/Contents.json`)
- ✅ Light and Dark PNG files exist
- ⚠️ Needs proper Xcode build or `actool` compilation

## 📝 Recommended Workflow

### For Development:
```bash
./run_app.sh
```

### For Production:
1. Open in Xcode
2. Archive the app (Product → Archive)
3. Export for distribution
4. App icon will automatically support Dark Mode

## 🔍 Verifying Dark Mode Support

After building in Xcode:
```bash
# Check if dark icon exists
ls -la CleanME.app/Contents/Resources/Assets.car

# The .car file contains both light and dark assets
```

## 📚 References

- [Apple: Asset Catalog Format](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)
- [actool Documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapplicationicon)
