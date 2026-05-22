# Contributing to GXNUTool

Thank you for considering contributing code, documentation, or issue feedback to GXNUTool. This document describes the recommended collaboration workflow for this project.

## Project Positioning

GXNUTool / GXNU Class Tool is a Flutter-based course schedule tool for Guangxi Normal University, with current focus on unified identity authentication login, course schedule synchronization, local state persistence, Android/Windows user experience, and mobile performance.

This project involves campus accounts and schedule data. When contributing, please do not submit any real accounts, passwords, Cookies, Tokens, student IDs, names, schedule screenshots, captured traffic, or sensitive school internal interface information.

## Development Environment

Recommended environment:

- Flutter stable SDK
- Dart SDK bundled with Flutter
- Android Studio or VS Code
- Android physical device or emulator
- Windows desktop environment optional

Basic commands:

```sh
flutter doctor
flutter pub get
flutter analyze
flutter test
```

Run:

```sh
flutter run -d android
flutter run -d windows
```

Build:

```sh
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build windows --release --obfuscate --split-debug-info=./symbols
```

## Branch Workflow

Recommended branch model:

- `main`: Stable branch, only for releasable or verified versions.
- `dev`: Main development branch, for merging daily features and fixes.
- `feat/<name>`: New feature branch.
- `fix/<name>`: Bug fix branch.
- `refactor/<name>`: Structural adjustment branch.
- `docs/<name>`: Documentation branch.
- `release/<version>`: Release preparation branch.
- `hotfix/<name>`: Online emergency fix branch.

Typical workflow:

```sh
git checkout dev
git pull
git checkout -b feat/course-cache
# Modify code
dart format .
flutter analyze
flutter test
git commit -m "feat(course): add local schedule cache"
git push -u origin feat/course-cache
```

Then submit a Pull Request to `dev`. Before release, merge from `dev` to `main`.

## Commit Messages

This project uses the Conventional Commits style. Format:

```text
<type>(<scope>): <subject>
```

Examples:

```text
feat(auth): add login session restore
fix(schedule): handle empty week course list
perf(home): reduce first screen rebuilds
refactor(data): split api client and repositories
docs: add contribution guide
```

See [`docs/COMMIT_CONVENTION.md`](docs/COMMIT_CONVENTION.md) for detailed conventions.

## Pull Request Requirements

Before submitting a PR, please confirm:

- Code passes `dart format .`.
- Code passes `flutter analyze`.
- Relevant logic has tests or manual verification notes.
- Does not contain real accounts, passwords, Cookies, Tokens, schedule screenshots, or captured traffic.
- UI changes include screenshots or screen recording descriptions.
- Performance changes describe verification methods, such as startup time, page rebuilds, list scrolling, API request count, etc.
- Breaking changes describe impact scope and migration approach.

## Issue Feedback Requirements

When submitting a Bug, it is recommended to include:

- App version or commit;
- Flutter version;
- Device and system version;
- Reproduction steps;
- Expected result;
- Actual result;
- Logs or screenshots, sanitized.

## Code Style

- Maintain Dart null safety and strong typing; do not casually use `dynamic`.
- Prioritize splitting overly large controllers, API static classes, and page files.
- Network layer, repository layer, state layer, and UI layer responsibilities should remain clear.
- Async flows need to consider duplicate requests, concurrent login restore, cancellation, timeout, and error messaging.
- UI components should be as reusable as possible; avoid piling up large numbers of anonymous widgets inside pages.

See [`docs/STYLE_GUIDE.md`](docs/STYLE_GUIDE.md) for more details.

## Data and Security Requirements

This project prohibits committing the following:

- Real student IDs, names, passwords, verification codes, Cookies, Tokens;
- Real course schedule screenshots, interface response dumps, login traffic capture dumps;
- Unnecessarily sensitive parameters of school system internal interfaces;
- Locally generated keys, signing files, release keystore;
- `symbols/`, build artifacts, cache directories.

If you need to submit logs or interface examples, sanitize them first and use Mock data whenever possible.

## Suitable Contribution Directions

- Login restore and network error handling;
- Schedule caching, refreshing, offline fallback;
- UI simplification and componentization;
- Android/Windows adaptation;
- Startup performance, list scrolling, and page rebuild optimization;
- Unit tests, widget tests, and integration tests;
- README, development documentation, and release notes.
