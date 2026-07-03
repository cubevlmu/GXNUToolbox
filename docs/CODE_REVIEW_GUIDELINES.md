# Code Review Guidelines

This document standardizes code review for GXNUTool.

## Review Focus Points

### 1. Functional Correctness

Check:

- Whether the login flow covers success, failure, expiration, and network exceptions;
- Whether schedule sync handles empty data, interface failure, and semester/week switching;
- Whether local cache and login state may result in dirty data;
- Whether async requests may trigger repeatedly or have race conditions;
- Whether error messages are meaningful to users.

### 2. Privacy and Security

Check:

- Whether logs output student ID, password, Cookie, Token, or schedule details;
- Whether sample data is sanitized;
- Whether local storage properly uses secure storage;
- Whether network errors leak complete responses;
- Whether unnecessary permissions are added.

### 3. Architectural Boundaries

Check:

- Whether UI directly calls lower-level APIs;
- Whether Repository assumes clear data transformation responsibilities;
- Whether Controller is too heavy;
- Whether Widget mixes in too much business logic;
- Whether static utility classes continue to bloat.

### 4. Performance

Check:

- Whether first-screen blocking is introduced;
- Whether duplicate requests are increased;
- Whether heavy computations are performed in build;
- Whether lists, schedule grids, and skeleton screens cause excessive rebuilds;
- Whether there are unnecessary large objects resident in memory.

### 5. Maintainability

Check:

- Whether naming expresses intent;
- Whether files are too large;
- Whether error handling is centralized;
- Whether business rules have comments or documentation;
- Whether necessary tests are supplemented.

## Comment Style

Recommended comment format:

```md
It is suggested here to separate login restore and home page initialization. Currently both flows can trigger course sync, which can easily lead to duplicate requests on weak networks.

Suggestions:
1. AuthController only handles restoring login state;
2. ScheduleRepository handles course sync;
3. HomeController waits for auth ready before requesting schedule.
```

Avoid:

```md
This doesn't work.
There's a problem.
Rewrite.
```

## Pre-Merge PR Checks

- [ ] Commit message follows conventions.
- [ ] Impact scope is clear.
- [ ] `flutter analyze` passes or failure reason is explained.
- [ ] Core flows have been verified.
- [ ] No sensitive data.
- [ ] UI changes have screenshots or descriptions.
- [ ] Performance changes have verification methods.

## Acceptable Technical Debt

The following situations can be merged, but should leave TODO or Issue:

- Some exception states can only temporarily show generic errors;
- Some pages temporarily lack widget tests;
- Some interface meanings are not yet fully confirmed;
- Some UI details to be uniformly revised later.

Unacceptable:

- Real credentials or personal data entering the repository;
- Core login and schedule flows clearly unusable;
- Silently swallowing all errors;
- Large-scale refactoring without explanation or verification.
