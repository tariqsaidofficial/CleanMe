# 🎯 Production Setup - Dark Mode App Icon

## ✅ الحل النهائي (3 خطوات فقط!)

### الخطوة 1: افتح في Xcode
```bash
open Package.swift
```

### الخطوة 2: عدل Build Settings

1. في Xcode، اختار **CleanME** target من القائمة اليسار
2. روح لـ **Build Settings** tab
3. دور على `ASSETCATALOG_COMPILER_APPICON_NAME`
4. اضبطه على: `AppIcon`

**أو** استخدم Terminal:

```bash
# Add to Package.swift in the target settings
swiftSettings: [
    .unsafeFlags([
        "-Xfrontend", "-enable-upcoming-feature",
        "-Xfrontend", "BareSlashRegexLiterals"
    ])
],
linkerSettings: [
    .linkedFramework("SwiftUI"),
    .linkedFramework("AppKit"),
    .unsafeFlags([
        "-Xlinker", "-sectcreate",
        "-Xlinker", "__TEXT",
        "-Xlinker", "__info_plist",
        "-Xlinker", "Info.plist"
    ])
]
```

### الخطوة 3: Build للإنتاج

```bash
# استخدم السكريبت الجاهز
./build_release.sh
```

**أو** من Xcode:
1. Product → Archive
2. Distribute App
3. Export

---

## 🎨 التأكد من Dark Mode

بعد البناء:

```bash
# 1. افتح التطبيق
open CleanME.app

# 2. غير System Appearance
# System Settings → Appearance → Light/Dark

# 3. الأيقونة في الـ Dock هتتغير! ✨
```

---

## 📦 الملفات المهمة

### ✅ موجودة ومضبوطة:

1. **Info.plist** - يحتوي على:
   ```xml
   <key>CFBundleIconFile</key>
   <string>AppIcon</string>
   <key>CFBundleIconName</key>
   <string>AppIcon</string>
   ```

2. **Assets.xcassets/AppIcon.appiconset/** - يحتوي على:
   - `icon-16.png` → `icon-512@2x.png` (Light)
   - `icon-16-dark.png` → `icon-512@2x-dark.png` (Dark)
   - `Contents.json` (مع appearances)

3. **build_release.sh** - يستخدم `actool` لتجميع الأيقونات

---

## 🚀 للتوزيع النهائي

### Option 1: DMG (Recommended)
```bash
# سيتم إنشاء create_dmg.sh قريباً
./create_dmg.sh
```

### Option 2: App Store
1. Open in Xcode
2. Product → Archive
3. Distribute to App Store

### Option 3: Direct Distribution
```bash
# Build
./build_release.sh

# Code Sign
codesign --force --deep --sign "Developer ID Application: Your Name" CleanME.app

# Notarize (optional)
xcrun notarytool submit CleanME.app --wait

# Create ZIP
ditto -c -k --keepParent CleanME.app CleanME.zip
```

---

## ✅ Checklist

- [x] Info.plist يحتوي على `CFBundleIconFile` و `CFBundleIconName`
- [x] Assets.xcassets يحتوي على Light و Dark variants
- [x] build_release.sh يستخدم `actool` بشكل صحيح
- [x] Dark Mode يشتغل في Development
- [ ] **TODO**: اختبار في Production build
- [ ] **TODO**: اختبار على macOS مختلفة (13.0+)

---

## 🐛 Troubleshooting

### المشكلة: الأيقونة مش بتتغير في Dark Mode

**الحل 1**: تأكد إن الـ build استخدم `actool`:
```bash
# Check if Assets.car exists
ls -la CleanME.app/Contents/Resources/Assets.car
```

**الحل 2**: امسح الـ cache:
```bash
rm -rf ~/Library/Caches/com.apple.iconservices.store
killall Dock
```

**الحل 3**: أعد بناء التطبيق:
```bash
rm -rf .build CleanME.app
./build_release.sh
```

---

## 📚 المراجع

- [Apple: Asset Catalog Format](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_ref-Asset_Catalog_Format/)
- [Dark Mode Icons](https://developer.apple.com/design/human-interface-guidelines/dark-mode)
- [actool Documentation](https://keith.github.io/xcode-man-pages/actool.1.html)
