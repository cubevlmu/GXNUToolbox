# GXNU Class Tool

<a id="readme-top"></a>

[![Flutter][flutter-shield]][flutter-url]
[![Dart][dart-shield]][dart-url]
[![GetX][getx-shield]][getx-url]

<br />
<div align="center">
  <img src="assets/images/icon.png" alt="GXNU Class Tool Logo" width="120" height="120">

  <h3 align="center">GXNU Class Tool</h3>

  <p align="center">
    A Flutter course schedule application for Guangxi Normal University.
    <br />
    Focused on unified identity authentication login, schedule synchronization, Material Design experience, and a lightweight, stable mobile user experience.
  </p>
</div>

## Table of Contents

- [About The Project](#about-the-project)
- [Built With](#built-with)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Build Release](#build-release)
- [Notes](#notes)
- [Roadmap](#roadmap)

## About The Project

GXNU Class Tool is a Flutter-based course schedule tool for Guangxi Normal University. The current repository is primarily intended for Android and Windows environments.

Current project focus includes:

- Login and login state restoration based on unified identity authentication
- Semester and week switching with real-time schedule synchronization
- Home page today's course overview and schedule detail viewing
- Material Design 3 style mobile interface
- Local login information persistence, offline fallback, and basic performance optimization

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Built With

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [GetX](https://pub.dev/packages/get)
- [Dio](https://pub.dev/packages/dio)
- [Hive](https://pub.dev/packages/hive)
- [easy_refresh](https://pub.dev/packages/easy_refresh)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
- [package_info_plus](https://pub.dev/packages/package_info_plus)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Features

- Unified identity authentication login with remember login state support
- Splash page auto network check and login state sync
- Home page displays current semester, current week, and today's course schedule
- Schedule page supports semester switching, week switching, manual refresh, and course detail drawer
- Settings page supports theme mode switching, about page, and logout
- First-screen skeleton screen, controller lifecycle convergence, on-demand initialization, and other basic performance optimizations
- Android adaptive launch icon and Material 3 style theme

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Project Structure

```text
lib/
├── data/       # API, authentication storage, models, repository layer
├── pages/      # Login, home, schedule, settings, splash, etc. pages
├── utils/      # Network, logging, storage, dialogs, etc. utilities
├── widgets/    # Common components, bottom sheets, skeleton animations, etc.
├── class_tool_app.dart
└── main.dart
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

- Flutter stable SDK
- Dart SDK bundled with Flutter
- Android Studio, VS Code, or other Flutter IDE

Check local environment:

```sh
flutter doctor
```

### Installation

1. Clone the repository.

   ```sh
   git clone github.com/cubevlmu/GXNUTool.git
   cd class_tool
   ```

2. Install dependencies.

   ```sh
   flutter pub get
   ```

3. If you need to regenerate the app icon, run:

   ```sh
   dart run flutter_launcher_icons
   ```

### Run

```sh
flutter run
```

Examples:

```sh
flutter run -d android
flutter run -d windows
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Build Release

### Android

```sh
flutter build appbundle --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

### Windows

```sh
flutter build windows --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- The current project depends on school-related system interfaces. Interface structure or login policy changes may cause login failures.
- When verification codes, remote login verification, or excessive login failures are triggered, manual re-login may be required.
- The app stores necessary login information locally to support automatic login; remote account hosting is not implemented in this repository.
- It is recommended to verify startup speed, scrolling performance, and schedule loading experience in real device `release` mode.
- The repository currently does not include a separate license file. If open source release is planned, it is recommended to supplement later.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

- [x] Unified identity authentication login and login state restoration
- [x] Home page, schedule page, settings page basic functionality
- [x] Material Design 3 style theme with light/dark mode
- [x] Course detail drawer and week/semester switching
- [x] Home page skeleton screen and some startup performance optimizations
- [x] More complete README and module documentation
- [x] Better exception states and error messaging
- [x] More performance analysis and device-side verification
- [ ] Future expansion of more campus-related features

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[flutter-shield]: https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white
[flutter-url]: https://flutter.dev/
[dart-shield]: https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white
[dart-url]: https://dart.dev/
[getx-shield]: https://img.shields.io/badge/GetX-State%20Management-8A2BE2?style=for-the-badge
[getx-url]: https://pub.dev/packages/get
