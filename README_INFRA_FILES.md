# GXNUTool Infrastructure Files Description

This set of files is used to supplement the basic collaboration standards for the `cubevlmu/GXNUTool` repository and is suitable for direct copying to the repository root.

## File List

```text
.
├── AGENTS.md
├── CHANGELOG.md
├── CODE_OF_CONDUCT.md
├── CONTRIBUTING.md
├── SECURITY.md
├── SUPPORT.md
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── ISSUE_TEMPLATE/
│       ├── bug_report.md
│       ├── feature_request.md
│       ├── performance_report.md
│       └── refactor_task.md
└── docs/
    ├── AI_AGENT_GUIDELINES.md
    ├── BRANCHING_STRATEGY.md
    ├── CODE_REVIEW_GUIDELINES.md
    ├── COMMIT_CONVENTION.md
    ├── INFRASTRUCTURE_OVERVIEW.md
    ├── MAINTAINER_GUIDE.md
    ├── OPEN_SOURCE_CHECKLIST.md
    ├── PRIVACY_AND_DATA_GUIDELINES.md
    ├── RELEASE_PROCESS.md
    └── STYLE_GUIDE.md
```

## Recommended Commit Method

```sh
mkdir -p .github/ISSUE_TEMPLATE docs
# After copying the contents of this archive to the repository root:
git add AGENTS.md CHANGELOG.md CODE_OF_CONDUCT.md CONTRIBUTING.md SECURITY.md SUPPORT.md .github docs
git commit -m "docs: add project contribution and maintenance guidelines"
```

## Optional Future Supplement

- Choose and add a formal open source license, such as MIT, Apache-2.0, or GPL series.
- Depending on actual testing capability, supplement GitHub Actions, such as `flutter analyze`, `flutter test`, and Android build checks.
- If the project is publicly released, it is recommended to enable GitHub Security Advisories and supplement a formal security contact email.
