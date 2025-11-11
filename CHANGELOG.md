# Changelog

## [Unreleased]

### Added - 2025-11-12

- ✨ **Auto-navigation to Results**: App now automatically navigates to Results view after scan completes
- 🎨 **Dark Mode App Icon Support**: Full support for light/dark mode app icons in production builds
- ⚡ **Batch Processing for Deletion**: Concurrent file deletion with 50-file batches for 5-10x performance improvement
- 🔄 **Undo Functionality**: Added undo button (10-second window) to restore deleted files from Trash
- 📊 **Detailed Failure Reports**: Banner showing deletion failures with categorized error reasons
- 🔍 **Enhanced Error Detection**: Added file-in-use detection using `lsof` and permission checks
- 💡 **Performance Tips**: Added tip in deletion confirmation dialog to close apps for better performance
- 🛠️ **Production Build Script**: New `build_release.sh` for proper production builds with Dark Mode support

### Changed - 2025-11-12

- 🚀 **Deletion Performance**: Changed from sequential to concurrent batch processing (19k files: 5-8 min → 30-90 sec)
- 🎯 **Confirm Before Delete**: Now properly respects the setting in app preferences
- 🔘 **Button States**: Delete buttons now disabled during deletion operations
- 📝 **Info.plist**: Added `CFBundleIconFile` and `CFBundleIconName` for proper icon handling
- 🎨 **Asset Catalog**: Updated Logo.imageset with Dark Mode variants

### Fixed - 2025-11-12

- 🐛 **Auto-navigation Bug**: Fixed issue where app didn't navigate to Results after scan completion
- 🔒 **Permission Errors**: Added writable file checks before deletion attempts
- ⚠️ **Error Logging**: Enhanced logging for deletion failures with detailed error codes
- 🎨 **Dark Mode Icons**: Fixed production build to properly include dark mode app icons

### Documentation - 2025-11-12

- 📚 Added `BUILD_INSTRUCTIONS.md` for production build guidelines
- 📚 Added `PRODUCTION_SETUP.md` with complete Dark Mode setup instructions
- 📚 Added `SECURITY.md` for security policy and vulnerability reporting
- 📚 Added `VERSION` file for version tracking

## [Unreleased - Previous]

## [1.0.0] - 2023-10-01

### Added
- Initial release of CleanME.
- Implemented file scanning functionality in `ScanView`.
- Developed results display in `ResultsView`.
- Created settings interface in `SettingsView`.
- Added reusable `ProgressView` component for displaying progress.
- Established logging functionality in `Logger.swift`.
- Defined data models for cleanup items and scan results.

## [1.1.0] - 2023-10-15
### Added
- Support for Security-Scoped Bookmarks in file management.
- Enhanced reporting features with interactive elements in the app.

## [1.2.0] - 2023-10-30
### Added
- Introduced Privileged Helper for cleaning `/Library/*` with user permission.
- Added advanced options for exclusions and local trash limits.
- Enabled HTML report export with timestamp signing.

## [2.0.0] - 2023-11-15
### Added
- Implemented scheduling capabilities using LaunchAgents.
- Integrated automatic updates with Sparkle.
- Developed a Rule Engine for advanced exclusions.

## [2.1.0] - 2023-12-01
### Fixed
- Resolved various bugs related to file scanning and cleanup processes.
- Improved user interface responsiveness and performance.

## [2.2.0] - 2023-12-15
### Changed
- Updated user interface to adhere more closely to Human Interface Guidelines.
- Enhanced accessibility features for better user experience.

## [2.3.0] - 2024-01-01
### Added
- Introduced new logging features for better error tracking.
- Added support for additional file types in cleanup processes.

## [2.4.0] - 2024-01-15
### Changed
- Refined the cleanup algorithm for improved efficiency.
- Updated documentation and user guides for clarity.

## [2.5.0] - 2024-02-01
### Added
- New settings options for user customization.
- Enhanced security measures for file access and management.