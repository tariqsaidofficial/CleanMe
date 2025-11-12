# 🧩 CleanME – Application Metadata

## 🖥️ System Compatibility
| Category | Requirement |
|-----------|--------------|
| **Minimum macOS Version** | macOS 13.0 (Ventura) |
| **Supported macOS Versions** | macOS 13 Ventura – macOS 15 Sequoia |
| **Architecture** | Apple Silicon (M1, M2, M3) and Intel x86_64 |
| **Build System** | Swift Package Manager / Xcode 15+ |
| **App Format** | Universal Binary |
| **Sandboxed** | Yes |
| **Root Access Required** | No |
| **Privacy** | Fully local – no data collection |

## 📦 Packaging
| Type | Description |
|------|--------------|
| `.dmg`  | Standard drag-and-drop installer (recommended for users) |
| `.pkg`  | Signed installer for enterprise or MDM deployment |

## 🔧 Build Details
| Key | Value |
|-----|--------|
| **Scheme Name** | CleanME |
| **Bundle Identifier** | com.cleanme.app |
| **Version** | 1.0.0 |
| **Build Number** | 100 |
| **Team ID** | (Your Apple Developer Team ID) |
| **Signing Identity** | Developer ID Application |
| **Distribution Method** | Manual Release (GitHub) |

## 🔒 Security
- ✅ Sandboxed per Apple guidelines  
- ✅ Hardened Runtime enabled  
- ✅ Notarized via Xcode (optional for GitHub release)

---

### 📜 Notes
- Built and tested on macOS 14 Sonoma.  
- Backward compatible to macOS 13 Ventura verified via Xcode SDK.  
- DMG version supports drag-and-drop install.  
- PKG version supports silent install via `installer`  command.
