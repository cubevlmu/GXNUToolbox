# Commit Message Convention

GXNUTool uses the Conventional Commits style for easier changelog maintenance, release note generation, and issue tracing.

## Basic Format

```text
<type>(<scope>): <subject>
```

`scope` can be omitted:

```text
<type>: <subject>
```

Examples:

```text
feat(auth): add login session restore
fix(schedule): handle empty week course list
perf(home): reduce first screen rebuilds
refactor(data): split api client and repositories
docs: add contribution guide
```

## Type List

| type | Meaning | Example |
| --- | --- | --- |
| `feat` | New feature | `feat(schedule): add week switcher` |
| `fix` | Bug fix | `fix(auth): handle expired session` |
| `perf` | Performance optimization | `perf(home): reduce startup requests` |
| `refactor` | Refactoring, no external behavior change | `refactor(data): extract course repository` |
| `docs` | Documentation | `docs: update build instructions` |
| `style` | Code formatting or minor UI style tweaks | `style(settings): adjust section spacing` |
| `test` | Tests | `test(schedule): add parser tests` |
| `build` | Build system | `build(android): update launcher icon config` |
| `ci` | CI configuration | `ci: add flutter analyze workflow` |
| `chore` | Engineering housekeeping | `chore(deps): update dependencies` |
| `revert` | Rollback | `revert: revert schedule cache change` |
| `release` | Release version | `release: prepare 0.8.0` |

## Recommended scope

| scope | Applicable range |
| --- | --- |
| `app` | App entry, lifecycle, global config |
| `auth` | Login, unified identity authentication, login restore |
| `api` | API Client, request encapsulation, interceptors |
| `data` | Overall data layer adjustments |
| `repo` | Repository |
| `schedule` | Schedule, semester, week, course details |
| `home` | Home page |
| `settings` | Settings page |
| `storage` | Hive, secure storage, local cache |
| `ui` | General interface and visuals |
| `theme` | Theme, colors, light/dark mode |
| `widget` | General widgets |
| `notification` | Local notifications |
| `worker` | Background tasks |
| `android` | Android platform |
| `windows` | Windows platform |
| `deps` | Dependency upgrades |
| `docs` | Documentation |
| `ci` | CI/CD |
| `test` | Tests |

## subject Rules

- Use lowercase start in English; keep short and clear.
- Do not end with a period.
- Describe "what was done"; do not write vague descriptions.
- Single line should not exceed 72 characters.

Recommended:

```text
fix(auth): avoid duplicate session restore
```

Not recommended:

```text
fix: bug
update code
修了一下
```

## commit body

More complex commits should add a body explaining reason, impact scope, and verification method:

```text
refactor(data): split api client and repositories

Separate raw HTTP requests from business repositories so schedule pages no longer depend on the static Api class directly.

Validation:
- flutter analyze
- flutter test
```

## Breaking Changes

Breaking changes must be noted in the body or footer:

```text
refactor(storage)!: change cached schedule schema

BREAKING CHANGE: old Hive schedule cache will be ignored and regenerated after login.
```

## Revert

Rollback commits use:

```text
revert: revert "feat(schedule): add local cache"
```

Explain the reason for the rollback in the body.

## One Commit, One Category of Things

Avoid mixing unrelated changes. For example, do not complete all of the following in a single commit:

- Login fix;
- UI overhaul;
- Dependency upgrade;
- Formatting the entire repository.

If large-scale formatting is truly necessary, it should be a separate commit.
