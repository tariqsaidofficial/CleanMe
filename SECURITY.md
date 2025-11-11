# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within CleanME, please send an email to **support@dxbmark.com**. All security vulnerabilities will be promptly addressed.

### Please include the following information:

- Type of issue (e.g. buffer overflow, SQL injection, cross-site scripting, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit the issue

### What to expect:

- **Acknowledgment**: We will acknowledge your email within 48 hours
- **Updates**: We will send you regular updates about our progress
- **Fix**: If we confirm the issue, we will release a patch as soon as possible
- **Credit**: We will credit you in the security advisory (unless you prefer to remain anonymous)

## Security Best Practices

When using CleanME, we recommend:

1. **Run with Standard User Permissions**: CleanME is designed to work without admin privileges for most operations
2. **Review Before Deletion**: Always review the scan results before deleting files
3. **Enable Safe Mode**: Use the Safe Mode option in Settings to prevent deletion of critical system files
4. **Keep Updated**: Always use the latest version of CleanME to benefit from security patches
5. **Backup Important Data**: Always maintain backups of important files before performing cleanup operations

## Known Security Considerations

### File Access
- CleanME requires read access to scan directories
- Write access is only requested when deleting files
- All file operations are logged for audit purposes

### System Files
- Protected system files are excluded from scans by default
- Safe Mode provides additional protection against accidental deletion
- Admin privileges are requested only when necessary (e.g., cleaning `/Library/*`)

### Data Privacy
- CleanME does not collect or transmit any personal data
- All operations are performed locally on your machine
- No analytics or tracking are implemented

## Security Updates

Security updates will be released as soon as possible after a vulnerability is confirmed. Users will be notified through:

- GitHub Security Advisories
- Release notes in CHANGELOG.md
- In-app update notifications (if applicable)

## Third-Party Dependencies

CleanME is built with:
- SwiftUI (Apple)
- AppKit (Apple)

We regularly monitor these dependencies for security vulnerabilities and update them as needed.

## Contact

For security concerns, please email: **support@dxbmark.com**

For general questions, please use GitHub Issues.

---

**Last Updated**: November 12, 2025
