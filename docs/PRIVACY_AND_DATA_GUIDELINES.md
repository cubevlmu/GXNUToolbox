# Privacy and Data Guidelines

GXNUTool is a campus course schedule tool involving account authentication, local storage, course schedules, and school system interfaces. This document defines privacy requirements for data handling and contributions.

## Sensitive Data Types

The following are considered sensitive data:

- Student ID;
- Name;
- Password;
- Verification code;
- Cookies, Tokens, Sessions;
- Unified identity authentication responses;
- Real course schedules;
- Classroom locations, teacher names, class sections, and other identifiable information;
- Complete interface responses;
- Complete traffic captures;
- Release keystore, private keys, signing files.

## Prohibited Repository Content

Do not commit:

- Screenshots containing real accounts;
- Unsanitized logs;
- Traffic capture files;
- Real interface response JSON/HTML;
- Local secure storage / Hive data files;
- Build artifacts that may contain symbols or keys.

## Logging Standards

Logs may include:

- Whether a request succeeded;
- Status code;
- Module name;
- Sanitized error type;
- Duration;
- Whether cache was hit.

Logs must not include:

- Password;
- Cookie;
- Token;
- Complete request headers;
- Complete course schedule;
- Complete authentication response;
- Unsanitized user identifiers.

Example:

```dart
logger.i('schedule sync success, term=$termId, week=$week, cost=${costMs}ms');
logger.w('auth restore failed: session expired');
```

Not recommended:

```dart
logger.d('password=$password cookie=$cookie response=$body');
```

## Test Data

Tests should use Mock data. Example:

```text
Course name: Test Course A
Teacher: Teacher A
Location: Room A101
Weeks: Weeks 1-16
```

Do not use real course, real teacher, real location combinations.

## Local Storage Principles

- Login credentials should preferentially use `flutter_secure_storage`.
- Non-sensitive caches may use Hive, but should still avoid storing complete sensitive responses.
- When logging out, authentication state and user-related caches should be cleaned up.
- Cache structure changes should consider old data migration or proactive invalidation.

## UI Screenshot Standards

Before publishing screenshots, obscure:

- Name;
- Student ID;
- Course schedule details;
- Teacher and location;
- Notification content;
- Any personally identifiable information.

## Security Issue Handling

If sensitive data is found to have entered the repository:

1. Immediately delete the relevant content.
2. If already pushed, consider rewriting history or revoking leaked credentials.
3. Check whether release, issues, PRs, and actions artifacts also contain leaked content.
4. Handle under the `SECURITY.md` process.
