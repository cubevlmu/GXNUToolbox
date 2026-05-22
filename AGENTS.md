# AGENTS.md

This file is for code agents such as Codex, DeepSeek Agent, Copilot Workspace, etc. Agents should comply with the following constraints before modifying GXNUTool.

## Project Background

GXNUTool / GXNU Class Tool is a Flutter-based course schedule application for Guangxi Normal University. Current focuses are:

- Unified identity authentication login;
- Schedule synchronization;
- Local login state preservation;
- Basic Android and Windows experience;
- UI simplification, startup performance, and network layer stability.

## Allowed Priority Modification Directions

- Split oversized API, Repository, Controller, and page files;
- Fix duplicate login restore execution, concurrent requests, unclear error messages;
- Optimize schedule cache, refresh, offline fallback;
- Optimize UI structure, reduce the complexity brought by default Material styles;
- Reduce first-screen rebuilds, duplicate requests, and meaningless initialization;
- Supplement tests, documentation, Issue/PR templates, and release processes.

## Prohibited Actions

Agents must not:

- Submit real accounts, passwords, Cookies, Tokens, verification codes, schedule screenshots, or captured traffic;
- Hardcode school interface data into tests or documentation;
- Introduce unannounced large-scale architectural migrations;
- Replace state management, routing, networking libraries, or storage solutions without explaining impact;
- Silently delete existing features;
- Use dependencies or platform APIs that would break Android/Windows builds;
- Pursue visual effects alone in UI changes at the expense of usability, accessibility, and small-screen adaptation.

## Modification Principles

1. Commit in small steps; commit messages must follow Conventional Commits.
2. Keep clear separation of responsibilities across network layer, repository layer, state layer, and UI layer.
3. For async login, course sync, refresh, and similar flows, consider duplicate calls and error recovery.
4. Prioritize abstracting UI components into reusable widgets; do not pile complex anonymous closures in pages.
5. All logs must be sanitized; do not output credentials or complete personal course information.
6. For uncertain business behavior, add TODO comments or documentation notes first; do not fabricate interface meanings.

## Recommended Check Commands

At minimum, run after modifications:

```sh
dart format .
flutter analyze
flutter test
```

For platform builds, run as needed:

```sh
flutter build apk --debug
flutter build windows --debug
```

## PR Output Requirements

When agents submit PRs or patch descriptions, include:

- What was modified;
- Why it was modified;
- Which pages/modules were affected;
- Executed check commands;
- Reason for any unexecuted checks;
- Whether privacy, authentication, storage, or network requests changed;
- UI change screenshots or descriptions.

## Recommended Commit Types

```text
feat(auth): add login session restore
fix(schedule): handle empty course list
perf(home): reduce first screen rebuilds
refactor(data): split api client and repositories
docs: add project infrastructure guidelines
test(schedule): add course parser tests
```
