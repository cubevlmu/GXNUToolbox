# Style Guide

This document defines code and UI style recommendations for GXNUTool.

## Dart Code Style

- Use `dart format .` for consistent formatting.
- Avoid unnecessary `dynamic`.
- Avoid deep nesting; split complex logic into private methods.
- Avoid executing network requests, file IO, or heavy computations in widget `build`.
- Async methods should have clear error handling and loading states.
- Naming should express business meaning; do not use `data1`, `temp2`, `xxx` or similar temporary names.

## Layering Recommendations

Recommended responsibilities:

```text
UI Widget
  ↓
Controller / ViewModel
  ↓
Repository
  ↓
Api Client / Local Storage
```

### UI Widget

Responsible for displaying state and triggering user actions; do not directly assemble lower-level interface parameters.

### Controller

Responsible for page state, lifecycle, and user action orchestration. Do not put HTTP details and complex parsing logic into Controller.

### Repository

Responsible for business data retrieval, caching, transformation, and error normalization.

### Api Client

Responsible for request construction, interceptors, Cookie, timeout, and basic response parsing encapsulation.

## UI Style

The project can gradually converge from complex Material default aesthetics to a cleaner campus tool style. Recommendations:

- Clear page hierarchy; avoid excessive card nesting;
- Restrained color usage; reduce large areas of high-saturation color blocks;
- Maintain sufficient whitespace;
- Clear information priority; today's courses, current week, refresh status should be more prominent;
- Lightweight animations that do not affect responsiveness;
- Pay attention to contrast in dark mode;
- Small screen first, then adapt for Windows wide screen.

## Error Messages

Error messages should be as specific as possible:

Recommended:

```text
Login session expired. Please log in again.
The network is currently unavailable. Showing locally cached schedule.
Schedule sync failed. You can pull to refresh later.
```

Not recommended:

```text
Error
Failed
Exception
```

## Performance Recommendations

- Login restore should only be executed once; avoid multiple pages triggering it repeatedly.
- Schedule sync should have deduplication and caching strategies.
- Large pages should be split into widgets to reduce full-page rebuilds.
- Lists and schedule grids should use stable keys and lightweight build logic whenever possible.
- Image assets should be compressed before committing.
- Only initialize background tasks, notifications, package info modules when necessary.

## File Organization

It is recommended to continue with the current structure:

```text
lib/
├── data/
├── pages/
├── utils/
├── widgets/
├── class_tool_app.dart
└── main.dart
```

Can be further refined to:

```text
lib/
├── app/
├── core/
├── data/
│   ├── api/
│   ├── models/
│   ├── repositories/
│   └── storage/
├── features/
│   ├── auth/
│   ├── home/
│   ├── schedule/
│   └── settings/
└── widgets/
```

Migrations should be done in small steps to avoid breaking a large number of references at once.
