# Release Process

This document describes the recommended release process for GXNUTool.

## Pre-Release Checks

Before releasing, confirm:

- Code on `main` or `release/<version>` branch is stable;
- `version` in `pubspec.yaml` has been updated;
- `CHANGELOG.md` has been updated;
- No real accounts, Cookies, Tokens, schedule data, or captured traffic;
- Core flows such as login, schedule sync, settings page, and logout have been verified;
- Android release build can complete;
- Windows release build verified as needed.

## Version Number Rules

Semantic versioning is recommended:

```text
MAJOR.MINOR.PATCH+BUILD
```

Example:

```yaml
version: 0.8.0+8
```

Recommended meanings:

- `MAJOR`: Breaking changes or major architectural upgrades;
- `MINOR`: New features;
- `PATCH`: Bug fixes;
- `BUILD`: Incrementing mobile build number.

## Release Branch

Branch off from `dev`:

```sh
git checkout dev
git pull
git checkout -b release/0.8.0
```

Update:

- `version` in `pubspec.yaml`;
- Version record in `CHANGELOG.md`;
- Necessary build instructions or screenshots in README.

Commit:

```sh
git add pubspec.yaml CHANGELOG.md README.md
git commit -m "release: prepare 0.8.0"
```

## Check Commands

```sh
flutter clean
flutter pub get
dart format .
flutter analyze
flutter test
```

Android:

```sh
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build appbundle --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

Windows:

```sh
flutter build windows --release --obfuscate --split-debug-info=./symbols
```

## Manual Acceptance Checklist

- [ ] First launch works normally.
- [ ] Reasonable prompts when network is unavailable.
- [ ] Can enter home page after successful login.
- [ ] Login state can be restored after closing the app.
- [ ] Current semester and current week display correctly.
- [ ] Schedule page can switch weeks.
- [ ] Course details can be opened.
- [ ] Settings page can switch themes.
- [ ] Local state is properly cleaned after logout.
- [ ] No obvious lag or white screen in Release mode.

## Creating Tags

After merging to `main`:

```sh
git checkout main
git pull
git tag v0.8.0
git push origin v0.8.0
```

## GitHub Release Text Structure

Recommended structure:

```md
## GXNUTool 0.8.0

### New Features

- ...

### Fixes

- ...

### Performance

- ...

### Notes

- ...
```

## After Release

- Merge `main` back into `dev`.
- Close completed Issues.
- Record known issues.
- If there are security fixes, remind users to update as soon as possible.
