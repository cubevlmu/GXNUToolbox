# Maintainer Guide

This document is for GXNUTool maintainers.

## Daily Maintenance Tasks

Recommended periodic tasks:

- Check if Issues are reproducible;
- Delete or remind users to remove sensitive logs;
- Organize TODOs and milestones;
- Update dependencies;
- Check Android/Windows builds;
- Update README and CHANGELOG;
- Clean up stale branches.

## Issue Handling

### Bug

Processing order:

1. Check if sensitive data is included.
2. Confirm whether reproduction steps are complete.
3. Determine if it is an app issue, school interface change, network issue, or user environment issue.
4. Apply labels: `bug`, `auth`, `schedule`, `ui`, `performance`, etc.
5. If reproducible, add to fix plan; if not, request additional information.

### Feature

Judgment:

- Whether it fits the campus course schedule tool positioning;
- Whether it introduces privacy or background permission risks;
- Whether it affects UI simplicity;
- Whether it significantly increases maintenance cost.

### Security

Prioritize private handling; do not disclose vulnerability details in public Issues.

## PR Handling

Checks before merging:

- Whether commit messages follow the convention;
- Whether sensitive data is included;
- Whether basic checks pass;
- Whether it affects login, schedule, or local storage;
- Whether UI changes have screenshots;
- Whether large changes have design descriptions.

## Label Recommendations

Recommended usage:

```text
bug
enhancement
documentation
performance
refactor
security
auth
schedule
ui
android
windows
good first issue
help wanted
blocked
```

## Version Maintenance

Before each release:

- Update `pubspec.yaml`;
- Update `CHANGELOG.md`;
- Check README;
- Build release package;
- Create tag;
- Write GitHub Release.

## Sensitive Information Handling

If users submit sensitive information in Issues/PRs:

1. Immediately remind the user to delete or edit.
2. Maintainers can delete relevant comments or hide content.
3. If content enters git history, evaluate whether history rewriting is needed.
4. If credentials are still valid, prompt immediate revocation.

## Dependency Upgrade Strategy

Before upgrading:

```sh
flutter pub outdated
```

After upgrading:

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d android
```

Key areas to watch:

- GetX lifecycle changes;
- Dio/Cookie behavior changes;
- Secure storage platform behavior changes;
- Android permissions and background task policy changes;
- Windows build compatibility.
