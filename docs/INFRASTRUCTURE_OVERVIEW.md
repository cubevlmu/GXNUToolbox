# Infrastructure Overview

This document provides an overview of GXNUTool's repository infrastructure files and their purposes.

## Root Directory Files

| File | Purpose |
| --- | --- |
| `CODE_OF_CONDUCT.md` | Contributor code of conduct |
| `CONTRIBUTING.md` | Contribution workflow, environment, PR requirements |
| `SECURITY.md` | Security issue reporting and sensitive data handling |
| `SUPPORT.md` | User feedback and support instructions |
| `CHANGELOG.md` | Version update records |
| `AGENTS.md` | Constraints for AI agents modifying the project |

## `.github` Files

| File | Purpose |
| --- | --- |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR template |
| `.github/ISSUE_TEMPLATE/bug_report.md` | Bug template |
| `.github/ISSUE_TEMPLATE/feature_request.md` | Feature suggestion template |
| `.github/ISSUE_TEMPLATE/performance_report.md` | Performance issue template |
| `.github/ISSUE_TEMPLATE/refactor_task.md` | Refactoring task template |

## `docs` Files

| File | Purpose |
| --- | --- |
| `docs/COMMIT_CONVENTION.md` | Commit message conventions |
| `docs/BRANCHING_STRATEGY.md` | Branching strategy |
| `docs/RELEASE_PROCESS.md` | Release process |
| `docs/CODE_REVIEW_GUIDELINES.md` | Code review standards |
| `docs/PRIVACY_AND_DATA_GUIDELINES.md` | Privacy and data handling standards |
| `docs/STYLE_GUIDE.md` | Dart, Flutter, UI style standards |
| `docs/AI_AGENT_GUIDELINES.md` | Prompt templates for collaborating with AI agents |
| `docs/MAINTAINER_GUIDE.md` | Daily operation suggestions for maintainers |
| `docs/OPEN_SOURCE_CHECKLIST.md` | Pre-public-release checklist |

## Recommended Landing Order

1. First commit root directory docs and `.github` templates.
2. Then add collaboration standards under `docs`.
3. Later add CI: `flutter analyze`, `flutter test`, Android debug build.
4. Supplement formal LICENSE before project goes public.

## Recommended First Commit

```sh
git add AGENTS.md CHANGELOG.md CODE_OF_CONDUCT.md CONTRIBUTING.md SECURITY.md SUPPORT.md .github docs
git commit -m "docs: add project infrastructure guidelines"
```
