# Security Policy

## Supported Versions

The current project is still in an early development stage. It is recommended to submit security issue feedback only for the latest `main` branch and the latest release version. Historical versions are not guaranteed fixes.

| Version/Branch | Security Fix Status |
| --- | --- |
| `main` | Supported |
| Latest release | Best effort support |
| Older versions | Not guaranteed |

## Content Not to Disclose Publicly

GXNUTool involves unified identity authentication and course schedule data. Please do not disclose in public Issues, PRs, comments, screenshots, logs, or attachments:

- Student IDs, names, passwords, verification codes;
- Cookies, Tokens, Sessions, authentication responses;
- Real course schedules, course details, teacher information, classroom locations, and other personally identifiable data;
- Complete traffic captures, complete interface responses, sensitive school internal system paths;
- Keystore, signing certificates, private keys, `.env`, local configuration files.

If you need to describe an issue, please use sanitized minimal reproduction cases.

## Reporting Security Issues

If you discover the following issues, please do not disclose details publicly:

- Account credentials may be leaked;
- Login state restoration has privilege escalation or session confusion risks;
- Local storage saves sensitive information in plaintext;
- Interface requests, logs, or exception reports contain sensitive data;
- Dependencies have critical vulnerabilities;
- The app has exploitable malicious input, path injection, or remote code execution risks.

Recommended handling:

1. Prioritize using GitHub Security Advisories or contacting maintainers privately.
2. Describe impact scope, reproduction steps, and the version you are using.
3. Sanitize necessary logs before providing them.
4. Do not disclose exploitation details before the fix is released.

## Security Fix Process

After receiving a report, maintainers should process as follows:

1. Confirm whether the issue is reproducible.
2. Determine impact scope: login, storage, network, logs, dependencies, or build artifacts.
3. Prioritize removing or blocking the spread of sensitive information.
4. Fix in a private branch or security branch.
5. Supplement regression tests or manual verification steps.
6. Release the fix version and prompt users to update if necessary.

## Dependency Security

Periodically check Flutter/Dart dependencies:

```sh
flutter pub outdated
flutter pub upgrade --dry-run
flutter analyze
flutter test
```

When upgrading authentication, networking, storage, notification, and background task related dependencies, focus on verifying:

- Whether login state is preserved;
- Whether Cookie and secure storage behavior changes;
- Whether Android background tasks and notification permissions are affected;
- Whether the Windows build still passes.
