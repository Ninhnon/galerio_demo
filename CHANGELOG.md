# Changelog

## [1.0.0] - 2025-04-03

### Added
- iOS Configuration Setup
  - Added required permissions to Info.plist for camera, photo library, and microphone access
  - Configured AppTransportSecurity for webview support
  - Set minimum iOS deployment target to 12.0
  - Added Firebase and GoogleSignIn pod dependencies
  - Configured Firebase initialization in AppDelegate.swift
  - Fixed OAuth configuration with correct REVERSED_CLIENT_ID in URL schemes
