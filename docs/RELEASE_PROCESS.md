# 🚀 Release Process Guide

This document outlines the complete release process for CleanME.

## 📋 Pre-Release Checklist

### **Code Quality**
- [ ] All tests passing
- [ ] Code review completed
- [ ] No critical bugs or security issues
- [ ] Performance benchmarks met
- [ ] Memory leaks checked

### **Documentation**
- [ ] CHANGELOG.md updated with new version
- [ ] README.md version badge updated
- [ ] API documentation updated (if applicable)
- [ ] Screenshots updated (if UI changes)

### **Build & Testing**
- [ ] Clean build successful
- [ ] App bundle created and tested
- [ ] Manual testing on multiple macOS versions
- [ ] Beta testing feedback incorporated

## 🏷️ Version Tagging Process

### **1. Semantic Versioning**
Follow the format: `MAJOR.MINOR.PATCH`

```bash
# Examples
v1.0.0    # Initial stable release
v1.1.0    # New features added
v1.1.1    # Bug fixes only
v2.0.0    # Breaking changes
```

### **2. Create and Push Tag**
```bash
# Create annotated tag with detailed message
git tag -a v1.0.0 -m "🎉 CleanME v1.0.0 - Initial Stable Release

✨ Features:
- Complete UI/UX redesign
- 8 advanced scan types
- Performance improvements
- Professional branding

🐛 Bug Fixes:
- Fixed memory leaks
- Improved error handling

📚 Documentation:
- Complete user guide
- API documentation"

# Push tag to remote
git push origin v1.0.0
```

## 📦 GitHub Release Process

### **1. Create Release**
1. Go to [GitHub Releases](https://github.com/tariqsaidofficial/CleanMe/releases)
2. Click "Draft a new release"
3. Select the tag (e.g., `v1.0.0`)
4. Fill in release details:

**Release Title Format:**
```
🎉 CleanME v1.0.0 - [Release Name]
```

**Release Description Template:**
```markdown
## 🎉 CleanME v1.0.0 - Initial Stable Release

### ✨ New Features
- Feature 1 description
- Feature 2 description

### ⚡ Performance Improvements
- Improvement 1
- Improvement 2

### 🐛 Bug Fixes
- Fix 1
- Fix 2

### 📚 Documentation
- Updated user guide
- API documentation

### 🔧 Technical Details
- Minimum macOS version: 13.0+
- Architecture: Universal (Apple Silicon + Intel)
- Build number: [build_number]

### 📥 Download
- **Recommended**: Download the `.dmg` file for easy installation
- **Advanced**: Use the source code for custom builds

### 🆕 What's Next?
See our [roadmap](docs/ROADMAP.md) for upcoming features in v1.1.0.
```

### **2. Attach Build Files**
- `CleanME-v1.0.0.dmg` - Main installer
- `CleanME-v1.0.0.zip` - Portable version
- `CleanME-v1.0.0-source.zip` - Source code archive

### **3. Release Settings**
- [ ] **Latest release** (for stable versions)
- [ ] **Pre-release** (for alpha/beta/rc versions)
- [ ] **Create discussion** (for community feedback)

## 🧪 Pre-Release Versions

### **Alpha Releases**
```bash
git tag -a v1.1.0-alpha.1 -m "CleanME v1.1.0-alpha.1 - Early Development"
```
- Mark as "Pre-release" in GitHub
- Limited distribution to core testers
- Expect bugs and incomplete features

### **Beta Releases**
```bash
git tag -a v1.1.0-beta.1 -m "CleanME v1.1.0-beta.1 - Feature Complete Testing"
```
- Mark as "Pre-release" in GitHub
- Wider testing audience
- Feature complete, bug fixing phase

### **Release Candidates**
```bash
git tag -a v1.1.0-rc.1 -m "CleanME v1.1.0-rc.1 - Release Candidate"
```
- Mark as "Pre-release" in GitHub
- Final testing before stable release
- No new features, only critical bug fixes

## 📊 Post-Release Tasks

### **Immediate (Day 1)**
- [ ] Update README.md version badge
- [ ] Announce on social media/blog
- [ ] Monitor for critical issues
- [ ] Update App Store listing (future)

### **Week 1**
- [ ] Collect user feedback
- [ ] Monitor crash reports
- [ ] Plan hotfix if needed
- [ ] Update download statistics

### **Month 1**
- [ ] Analyze usage metrics
- [ ] Plan next version features
- [ ] Update roadmap based on feedback

## 🔄 Hotfix Process

For critical bugs in production:

```bash
# Create hotfix branch from tag
git checkout -b hotfix/v1.0.1 v1.0.0

# Make fixes
# ... fix code ...

# Commit and tag
git commit -m "🐛 Fix critical bug in file deletion"
git tag -a v1.0.1 -m "🐛 CleanME v1.0.1 - Critical Bug Fix"

# Merge back to main branches
git checkout main
git merge hotfix/v1.0.1
git checkout develop  
git merge hotfix/v1.0.1

# Push everything
git push origin main develop v1.0.1
```

## 📈 Version History

| Version | Release Date | Type | Description |
|---------|-------------|------|-------------|
| v1.0.0 | 2025-11-12 | Major | Initial stable release |
| v1.1.0 | TBD | Minor | Enhanced settings |
| v1.2.0 | TBD | Minor | System integration |
| v2.0.0 | TBD | Major | Architecture upgrade |

---

## 🎯 Release Checklist Template

Copy this for each release:

```markdown
## Release v[X.Y.Z] Checklist

### Pre-Release
- [ ] Code quality checks passed
- [ ] Documentation updated
- [ ] Build and testing completed
- [ ] CHANGELOG.md updated
- [ ] Version tag created and pushed

### Release
- [ ] GitHub release created
- [ ] Build files attached
- [ ] Release notes published
- [ ] Social media announcement

### Post-Release
- [ ] Monitor for issues
- [ ] Collect feedback
- [ ] Plan next version
```
