# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application called "every football" - a web app wrapper that displays a web view of `https://every-football.kr`. The app includes location-based features, requesting user location permissions and passing coordinates to the web application.

## Development Commands

Use the `derry` task runner for common operations. Common commands:

- **Development**: `derry dev` - Run the app in development mode
- **Release**: `derry release` - Run the app in release mode  
- **Build iOS**: `derry build_ios` - Build IPA for iOS
- **Build Android**: `derry build_android` - Build App Bundle for Android
- **Build All**: `derry build` - Build both iOS and Android
- **Deploy iOS**: `derry deploy-ios` - Deploy to App Store via Fastlane
- **Deploy Android**: `derry deploy-android` - Deploy to Play Store via Fastlane  
- **Deploy All**: `derry deploy` - Deploy to both stores
- **Analysis**: `flutter analyze` - Run static analysis
- **Tests**: `flutter test` - Run unit tests

## Architecture

### Core Structure
- **main.dart**: Entry point, sets up MaterialApp with dark theme (`#282828`)
- **web_view_screen.dart**: Main screen containing InAppWebView with location integration
- **data/const.dart**: Constants including web URL and theme colors

### Key Dependencies
- `flutter_inappwebview`: Web view implementation
- `geolocator`: Location services
- `permission_handler`: Runtime permissions
- `flutter_launcher_icons`: App icon generation
- `flutter_native_splash`: Splash screen

### Location Integration
The app requests location permissions on startup and appends coordinates as URL parameters (`?lat=<lat>&lng=<lng>`) to the web application. A loading screen with the app logo is shown during location permission and acquisition.

### Build Configuration
- **Version**: 1.0.1+10
- **Target SDK**: Flutter ^3.8.1
- **Assets**: Logo images in `assets/logo/`
- **Deployment**: Fastlane setup for both iOS and Android with environment configuration

### Platform Support
Multi-platform Flutter app supporting iOS, Android, Web, macOS, Linux, and Windows with platform-specific native code in respective directories.