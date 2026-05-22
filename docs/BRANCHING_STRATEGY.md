# Branching Strategy

This document defines the recommended branching strategy for GXNUTool.

## Branch Responsibilities

### `main`

Stable branch. Requirements:

- Must build normally;
- Must not contain obvious blocking issues;
- Corresponds to released or ready-to-release versions;
- No direct daily development on this branch.

### `dev`

Main daily development branch. Requirements:

- Feature and fix branches are preferentially merged here;
- Must remain basically runnable;
- When entering a release cycle, branch off `release/<version>` from here.

### `feat/<name>`

New feature branch, e.g.:

```text
feat/schedule-cache
feat/simple-home-ui
feat/background-notification
```

### `fix/<name>`

Bug fix branch, e.g.:

```text
fix/login-restore-race
fix/empty-course-list
fix/windows-build
```

### `refactor/<name>`

Refactoring branch, e.g.:

```text
refactor/api-client
refactor/repository-layer
refactor/settings-page
```

### `docs/<name>`

Documentation branch, e.g.:

```text
docs/contributing-guide
docs/release-process
```

### `release/<version>`

Release preparation branch, e.g.:

```text
release/0.8.0
```

Used for:

- Updating `pubspec.yaml` version;
- Updating `CHANGELOG.md`;
- Fixing release-blocking issues;
- Executing build verification.

### `hotfix/<name>`

Emergency fix branch, branched off from `main`, merged back to both `main` and `dev` after fixing.

## Recommended Workflow

### Daily Features

```sh
git checkout dev
git pull
git checkout -b feat/schedule-cache
# Modify code
git commit -m "feat(schedule): add local cache"
git push -u origin feat/schedule-cache
```

PR target branch: `dev`.

### Release Process

```sh
git checkout dev
git pull
git checkout -b release/0.8.0
# Update pubspec.yaml and CHANGELOG.md
flutter analyze
flutter test
git commit -m "release: prepare 0.8.0"
```

PR target branch: `main`.

After release is complete, merge `main` back into `dev`:

```sh
git checkout dev
git pull
git merge main
git push
```

### Emergency Fixes

```sh
git checkout main
git pull
git checkout -b hotfix/login-expired-session
# Fix
git commit -m "fix(auth): handle expired session"
```

PR target branch: `main`. Sync back to `dev` after merging.

## Merge Strategy

Recommended:

- Small PRs can use squash merge.
- Important features or multi-commit refactorings can use merge commit.
- Keep commit messages clear; do not keep meaningless `update`, `fix bug`, `wip`.

## Branch Protection Suggestions

If the repository is public or has multiple collaborators, it is recommended to protect `main`:

- Prohibit direct push;
- Require PR;
- Require `flutter analyze` and tests to pass;
- Require at least one review;
- Prohibit commits containing sensitive information.
